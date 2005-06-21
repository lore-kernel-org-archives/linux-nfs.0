From: Christian Volkmann <CVolkmann@orga-systems.com>
Subject: [solved]Trouble with lockf on Tru64 client and linux NFS server
Date: Tue, 21 Jun 2005 13:31:34 +0200
Message-ID: <42B7FA96.7090809@orga-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DknRC-00041C-8f
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 11:25:30 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DknQw-0004Yg-KX
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 11:25:30 -0700
Received: from bakterius.eggenet.de ([80.66.0.67])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Dkh14-0006HG-Lp
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 04:34:07 -0700
Received: from mailrelay2.eggenet.de (mailrelay2.eggenet.de [80.66.0.50])
	by bakterius.eggenet.de (8.13.4/8.12.8) with ESMTP id j5LBVWP4022363
	for <nfs@lists.sourceforge.net>; Tue, 21 Jun 2005 13:31:32 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Solution => no_subtree_check

Hi to everybody,

I had some trouble with locks on a Tru64-NFS client.
"lockf(fd, F_TLOCK, 0)" did not work proper.

no_subtree_check was required for the /etc/exports.

NFS-server: Linux with kernel 2.6.11 ( regular SuSE 9.3 )
NFS-client: Tru64 4.0G

/mountpoint  => Mountpoint
/mountpoint/my => permission 770, owner "my"
/mountpoint/my/subdir => permission 770, owner "my"
/mountpoint/my/subdir/mylock => permission 770, owner "my"

The User "my" was not able to lock the file.

After "chmod 777 /mountpoint/my /mountpoint/my/subdir" the lock worked.

Please see below for a script to reproduce bahavior.

Best regards,

Christian

PS: Linux,AIX and Sun as client worked without no_subtree_check


================cut here for the script============
#!/bin/ksh

# Strange behavior of NFS-lock/permission

MYNAME=${0##*/}

howto()
{
        echo "Syntax: $MYNAME DIRECTORY-TO-CHECK" 1>&2
        exit 99
}

if [ $# -ne 1 ]
then
        howto
fi

TOCHECK=$1
if [ ! -d $TOCHECK ]
then
        echo
        echo "Create directory $TOCHECK"
        mkdir $TOCHECK
        if [ ! -d $TOCHECK ]
        then
                echo "can not create $TOCHECK"
        fi
fi
echo
echo "Create directory $TOCHECK/subdir , chmod 777 for $TOCHECK and $TOCHECK/subdir "
echo
chmod 777 $TOCHECK
mkdir $TOCHECK/subdir
chmod 777 $TOCHECK/subdir
echo "compile c-program"
export CC=gcc
cat > /tmp/$MYNAME.$$.c <<EOP
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <unistd.h>

put_err(const char *point)
{
perror(point);
}
main()
{
int fd,lock;
char b[100] = "$TOCHECK/subdir" ;
        strcat (b, "/");
        strcat(b,"mylock");
        unlink(b);
        fd = open (b, O_CREAT | O_RDWR, 0777);
        if ( fd <= 0 )
        {
                printf("Internal error: errno %d %s\n",errno,strerror(errno));
                exit(0);
        }
        errno=0;
        lock=lockf (fd, F_TLOCK, 0) ;
        if ( lock != 0 )
                printf("Error from lock:%d %d %s\n",lock,errno,strerror(errno));
        else
                printf("Lock OK: %d %d %s\n",lock,errno,strerror(errno));
        exit(lock);
}
EOP
${CC} -o /tmp/$MYNAME.$$.bin /tmp/$MYNAME.$$.c
if [ ! -x /tmp/$MYNAME.$$.bin ]
then
        echo "missing compiled program" 1>&2
        exit 1
fi
/tmp/$MYNAME.$$.bin

echo
echo "Try with no world rwx, chmod 770 for $TOCHECK and $TOCHECK/subdir "
echo
chmod 770 $TOCHECK/subdir
chmod 770 $TOCHECK
/tmp/$MYNAME.$$.bin
if [ $? -ne 0 ]
then
        echo "Fehler aufgetreten !"
fi

rm $TOCHECK/subdir/lockfile
rmdir $TOCHECK/subdir
rmdir $TOCHECK 2>/dev/null
rm /tmp/$MYNAME.$$.bin /tmp/$MYNAME.$$.c


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
