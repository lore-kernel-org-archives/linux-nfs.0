Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:32800 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726027AbeHGXKO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Aug 2018 19:10:14 -0400
Date: Tue, 7 Aug 2018 16:53:58 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Cedric Blancher <cedric.blancher@gmail.com>,
        Peter Scott <pjscott@jpl.nasa.gov>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 file lock reporting interface request
Message-ID: <20180807205358.GH18747@coeurl.usersys.redhat.com>
References: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
 <CALXu0UdHWGOnMYk-xGG6_GWGfdpXffc0U-+Ark0joEYvhPSh_g@mail.gmail.com>
 <20180807203419.GB18415@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/NkBOFFp2J2Af1nK"
In-Reply-To: <20180807203419.GB18415@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--/NkBOFFp2J2Af1nK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, 07 Aug 2018, J. Bruce Fields wrote:

> On Thu, Aug 02, 2018 at 08:50:20PM +0200, Cedric Blancher wrote:
> > Solaris and FreeBSD dtrace facility supports this functionality.
> > Unfortunately, Linux rejected dtrace for license issues, and instead
> > did... nothing.
> 
> I didn't think was this sort of question tracing was designed to
> answer--it's a question about the system state at a given time (who
> holds what locks), rather than a list of events.  But I know nothing
> about dtrace.

FWIW a couple of years ago I wrote a systemtap script (attached) that
dumps out some NFSv4 state info (mostly lock info) from nfsd.  I ran
it on a recent RHEL 7 kernel and it still works, so it should work on
Centos 7.

-Scott

> 
> --b.
> 
> > 
> > Ced
> > 
> > On 10 July 2018 at 04:28, Peter Scott <pjscott@jpl.nasa.gov> wrote:
> > > Hello.  I am with the institutional hosting service at NASA's Jet Propulsion
> > > Laboratory and we have been trying to find the answer to an apparently
> > > simple question.
> > >
> > > We are running an NFSv4 server on Centos 7 and we need to get the server to
> > > tell us which files it thinks are locked by which clients.  This is because
> > > we have observed failure modes where something apparently has a lock
> > > (because attempting to lock the file again blocks) but we can't find a
> > > client that has the lock. Finding out what the server believes would be
> > > critical to troubleshooting this.
> > >
> > > We tracked down Trond Myklebust and Neil Brown and conversation suggests
> > > that this is a function that is (a) not currently available and (b)
> > > reasonable to ask for.  So this is me suggesting that an interface be
> > > provided to have knfsd output its list of locked files and clients.
> > >
> > > Regards,
> > > Peter Scott
> > > Office of the CIO
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> > 
> > -- 
> > Cedric Blancher <cedric.blancher@gmail.com>
> > [https://plus.google.com/u/0/+CedricBlancher/]
> > Institute Pasteur
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--/NkBOFFp2J2Af1nK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfsd4.stp"

#!/usr/bin/env stap
/*
 * nfsd4.stp: Systemtap script to dump out a lot of nfs4 state info
 *            (RHEL 7 only, sorry)
 *
 * Author: Scott Mayhew <smayhew@redhat.com>
 *
 * Usage: stap -g nfsd4.stp
 *
 */

global width = 3

function output(depth:long, msg:string)
{
	printf("%*s%s\n", depth*width, "", msg)
}

%{
#include <linux/fs.h>
%}

function fl_type_str:string(type:long)
%{
	long type = (long)STAP_ARG_type;
	int len;
	STAP_RETVALUE[0] = '\0';
	switch (type) {
	case F_RDLCK:
		strlcat(STAP_RETVALUE, "F_RDLCK", MAXSTRINGLEN);
		break;
	case F_WRLCK:
		strlcat(STAP_RETVALUE, "F_WRLCK", MAXSTRINGLEN);
		break;
	case F_UNLCK:
		strlcat(STAP_RETVALUE, "F_UNLCK", MAXSTRINGLEN);
		break;
	}
	len = strlen(STAP_RETVALUE);
	if (len)
		STAP_RETVALUE[len] = '\0';
	else
		strlcat(STAP_RETVALUE, "0", MAXSTRINGLEN);

%}

function fl_flags_str:string(flags:long)
%{
	long flags = (long)STAP_ARG_flags;
	int len;
	STAP_RETVALUE[0] = '\0';
	if (flags & FL_POSIX)
		strlcat(STAP_RETVALUE, "FL_POSIX|", MAXSTRINGLEN);
	if (flags & FL_FLOCK)
		strlcat(STAP_RETVALUE, "FL_FLOCK|", MAXSTRINGLEN);
	if (flags & FL_DELEG)
		strlcat(STAP_RETVALUE, "FL_DELEG|", MAXSTRINGLEN);
	if (flags & FL_ACCESS)
		strlcat(STAP_RETVALUE, "FL_ACCESS|", MAXSTRINGLEN);
	if (flags & FL_EXISTS)
		strlcat(STAP_RETVALUE, "FL_EXISTS|", MAXSTRINGLEN);
	if (flags & FL_LEASE)
		strlcat(STAP_RETVALUE, "FL_LEASE|", MAXSTRINGLEN);
	if (flags & FL_CLOSE)
		strlcat(STAP_RETVALUE, "FL_CLOSE|", MAXSTRINGLEN);
	if (flags & FL_SLEEP)
		strlcat(STAP_RETVALUE, "FL_SLEEP|", MAXSTRINGLEN);
	if (flags & FL_DOWNGRADE_PENDING)
		strlcat(STAP_RETVALUE, "FL_DOWNGRADE_PENDING|", MAXSTRINGLEN);
	if (flags & FL_UNLOCK_PENDING)
		strlcat(STAP_RETVALUE, "FL_UNLOCK_PENDING|", MAXSTRINGLEN);
	if (flags & FL_LAYOUT)
		strlcat(STAP_RETVALUE, "FL_LAYOUT|", MAXSTRINGLEN);
	len = strlen(STAP_RETVALUE);
	if (len)
		STAP_RETVALUE[len - 1] = '\0';
	else
		strlcat(STAP_RETVALUE, "0", MAXSTRINGLEN);
%}

function net_generic:long(net:long, id:long)
{
	ng = rcu_dereference(@cast(net, "net")->gen)
	ptr = @cast(ng, "net_generic")->ptr[id-1]
	return(ptr)
}

function print_file_lock_info(filp, lo)
{
	output(4, sprintf("filp: %p", filp))
	d = @cast(filp, "file")->f_path->dentry
	output(5, sprintf("dentry: %p", d))
	output(6, sprintf("d_name: %s", d_name(d)))
	i = @cast(filp, "file")->f_inode
	output(5, sprintf("inode: %p", i))
	output(6, sprintf("ino: %d", @cast(i, "inode")->i_ino))
	fl = @cast(i, "inode")->i_flock
	while (fl != 0) {
		if (@cast(fl, "file_lock")->fl_owner == lo) {
			output(6, sprintf("file_lock: %p", fl))
			output(7, sprintf("fl_owner: %p", @cast(fl, "file_lock")->fl_owner))
			output(7, sprintf("fl_flags: %s", fl_flags_str(@cast(fl, "file_lock")->fl_flags)))
			output(7, sprintf("fl_type: %s", fl_type_str(@cast(fl, "file_lock")->fl_type)))
			output(7, sprintf("fl_start: %x", @cast(fl, "file_lock")->fl_start))
			output(7, sprintf("fl_end: %x", @cast(fl, "file_lock")->fl_end))
			o = @cast(fl, "file_lock")->fl_lmops
			output(7, sprintf("fl_lmops: %p", o))
		}
		fl = @cast(fl, "file_lock")->fl_next
	}
}

function print_nfs4_lock_stateid(stp:long)
{
	lo = @cast(stp, "nfs4_ol_stateid", "nfsd")->st_stateowner
	output(4, sprintf("nfs4_lockowner: %p", lo))
	for (i = 2; i >=0; i--) {
		filp = @cast(stp, "nfs4_ol_stateid", "nfsd")->st_stid->sc_file->fi_fds[i]
		if (filp != 0) {
			print_file_lock_info(filp, lo)
			break
		}
	}
}

function print_nfs4_openowner(oop:long)
{
	st_next = &@cast(oop, "nfs4_openowner", "nfsd")->oo_owner->so_stateids->next
	n = st_next
	while (@cast(n, "list_head")->next != st_next) {
		n = @cast(n, "list_head")->next
		stp = &@module_container_of(n, "nfsd", "nfs4_ol_stateid", st_perstateowner)
		output(3, sprintf("open stateid: %p", stp))
		lst_next = &@cast(stp, "nfs4_ol_stateid", "nfsd")->st_locks->next
		m = lst_next
		while (@cast(m, "list_head")->next != lst_next) {
			m = @cast(m, "list_head")->next
			lst = &@module_container_of(m, "nfsd", "nfs4_ol_stateid", st_locks)
			output(3, sprintf("lock stateid: %p", lst))
			print_nfs4_lock_stateid(lst)
		}
	}
}

function print_nfs4_client(clp:long)
{
	a = &@cast(clp, "nfs4_client", "nfsd")->cl_addr
	if (@cast(a, "sockaddr")->sa_family == 2) {
		output(2, sprintf("cl_addr: %s",
				format_ipaddr(@cast(a, "sockaddr_in")->sin_addr->s_addr, 2)))
        } else if (@cast(a, "sockaddr")->sa_family == 10) {
		output(2, sprintf("cl_addr: [%s]",
				format_ipaddr(&@cast(a, "sockaddr_in6")->sin6_addr, 10)))
	}
	cl_openowners = &@cast(clp, "nfs4_client", "nfsd")->cl_openowners
	n = cl_openowners
	while (@cast(n, "list_head")->next != cl_openowners) {
		n = @cast(n, "list_head")->next
		oop = &@module_container_of(n, "nfsd", "nfs4_openowner", oo_perclient)
		output(2, sprintf("nfs4_openowner: %p", oop))
		print_nfs4_openowner(oop)
	}
}

probe begin
{
	nfsd_net_id = kernel_int(&@var("nfsd_net_id@fs/nfsd/nfsctl.c", "nfsd"))
	output(0, sprintf("nfsd_net_id: %d", nfsd_net_id))
	nfsd_net = net_generic(&@var("init_net@net/core/net_namespace.c"), nfsd_net_id)
	output(0, sprintf("nfsd_net: %p", nfsd_net))
	client_lru = &@cast(nfsd_net, "nfsd_net", "nfsd")->client_lru
	output(0, sprintf("client_lru: %p", client_lru))
	n = client_lru
	while (@cast(n, "list_head")->next != client_lru) {
		n = @cast(n, "list_head")->next
		clp = &@module_container_of(n, "nfsd", "nfs4_client", cl_lru)
		output(1, sprintf("nfs4_client: %p", clp))
		print_nfs4_client(clp)
	}
	exit()
}

--/NkBOFFp2J2Af1nK--
