From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 882960: Busy inodes after unmount, oops
Date: Fri, 06 Feb 2004 09:23:04 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4022C248.D4FF17CD@melbourne.sgi.com>
References: <40209B6D.56ED461E@melbourne.sgi.com> <20040204120952.GA1980@suse.de> <4021751C.B888A15C@melbourne.sgi.com> <20040205161515.GA21344@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------F75F640360C258E2B77670A5"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
   Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aoru6-0004i0-8a
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 14:23:22 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aoru4-000234-N4
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 14:23:20 -0800
To: Olaf Kirch <okir@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------F75F640360C258E2B77670A5
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Olaf Kirch wrote:
> 
> Hi Greg,
> 
> On Thu, Feb 05, 2004 at 09:41:32AM +1100, Greg Banks wrote:
> > BTW (not directly related to this bug) I found by experiment that I
> > could umount an NFS mount when there were open file descriptors for
> > unlinked files in the mount,[...]
> 
> Then something else must be wrong big time.

Yes, I found that a surprising behaviour.

> > >  -      __rpc_execute notices the task is dead (no tk_action),
> > >         leaves the loop and invokes task->tk_exit == nfs_async_unlink_done
> >
> > No.  In a crash dump taken after the umount has completed, the dir dentry has
> > 1 leaked d_count for every async unlink present at umount, even though the
> > async unlink tasks have been cleaned up.  This indicates that task->tk_exit
> > is not being called but task->tk_release is, so the dput is not happening.
> 
> But then prune_dcache shouldn't touch these dentries at all, because their
> refcount is still 1. They would be leaked, but there would be no crash.

That makes sense.  I'll go back and recheck my forensics.

> > It's not entirely clear to me how __rpc_execute can do that, but the evidence
> > is that it does so.
> 
> Very strange... maybe we have a refcounting problem elsewhere, and the
> refcount was 2 before calling tk_exit? But somehow I doubt this... I
> think we'd see far more massive problems in this case.
> 
> Would you share your test case?

Sure, attached is a C program and a shell script wrapper.  You need to
adjust $SERVER and possibly $UDELAY in the shell script.  Then run the
shell script and watch /var/log/messages.

The C program is fairly generic, you can use it to test the other case
(umount allowed with open file descriptors) also.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
--------------F75F640360C258E2B77670A5
Content-Type: application/x-sh;
 name="fmeh.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fmeh.sh"

#!/bin/sh

i=1
SERVER=munch
EXPORT=/server
UDELAY=500
MOUNTPOINTBASE=/tmp/fmeh-mounts

do_silly_rename ()
{
    ./dangle "$1" \
	write"VERY SILLY INDEED" \
	unlink \
	write"EVEN SILLIER"
}

while true ; do
    MOUNTPOINT=`printf "$MOUNTPOINTBASE/%05d.d" $i`
    logger -p local7.error "fmeh.sh: $MOUNTPOINT UDELAY=$UDELAY"
    mkdir -p $MOUNTPOINT
    mount $SERVER:$EXPORT $MOUNTPOINT
    mkdir -p $MOUNTPOINT/foo/bar
    do_silly_rename $MOUNTPOINT/foo/bar/silly1.$i
    do_silly_rename $MOUNTPOINT/foo/bar/silly2.$i
    do_silly_rename $MOUNTPOINT/foo/bar/silly3.$i
    usleep $UDELAY
    umount $MOUNTPOINT
    i=`expr $i + 1`
#    UDELAY=`expr $UDELAY + $UDELAY`
done

--------------F75F640360C258E2B77670A5
Content-Type: text/plain; charset=us-ascii;
 name="dangle.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dangle.c"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <fcntl.h>

struct state
{
    const char **cmd;
    int fd;
    const char *path;
};


static void
do_one_command(const char *cmd, struct state *state)
{
    if (!strcmp(cmd, "unlink"))
    {
	fprintf(stderr, "dangle: unlink\n");
	unlink(state->path);
    }
    else if (!strncmp(cmd, "write", 5))
    {
	const char *data;

	data = cmd+5;
	if (!*data)
	    data = "X";
	fprintf(stderr, "dangle: write(\"%s\")\n", data);
	write(state->fd, data, strlen(data));
    }
    else if (!strcmp(cmd, "fsync"))
    {
	fprintf(stderr, "dangle: fsync\n");
	fsync(state->fd);
    }
    else if (!strcmp(cmd, "fdatasync"))
    {
	fprintf(stderr, "dangle: fdatasync\n");
	fdatasync(state->fd);
    }
    else if (!strcmp(cmd, "sigpause"))
    {
	fprintf(stderr, "dangle: sigpause\n");
	sigpause(0);
    }
    else if (!strncmp(cmd, "loop", 4))
    {
	int i, N;

	N = atoi(cmd+4);
	fprintf(stderr, "dangle: looping, N=%d\n", N);
	state->cmd++;
	if (N == 0)
	{
	    for (;;)
		do_one_command(*state->cmd, state);
	}
	else
	{
	    for (i = 0 ; i < N ; i++)
		do_one_command(*state->cmd, state);
	}
    }
    else
    {
	fprintf(stderr, "dangle: unknown command \"%s\"\n", cmd);
	exit(1);
    }
}


static void
do_commands(struct state *state)
{
    for ( ; *state->cmd != NULL ; state->cmd++)
    {
	do_one_command(*state->cmd, state);
    }
}



int
main(int argc, char **argv)
{
    struct state state;

    if (argc < 2)
    {
	fprintf(stderr, "Usage: dangle filename [command...]\n");
	exit(1);
    }
    state.path = argv[1];
    state.cmd = (const char **)argv+2;

    fprintf(stderr, "dangle: open(\"%s\")\n", state.path);
    state.fd = open(state.path, O_RDWR|O_CREAT, 0);
    if (state.fd < 0)
    {
	perror(state.path);
	exit(1);
    }

    do_commands(&state);

    fprintf(stderr, "dangle: exiting\n");
    return 0;
}


--------------F75F640360C258E2B77670A5--



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
