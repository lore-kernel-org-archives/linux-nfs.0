From: Brian Elliott Finley <finley@anl.gov>
Subject: Re: rpc.mountd at 99% cpu
Date: Thu, 29 Sep 2005 16:46:23 -0500
Message-ID: <433C60AF.30409@anl.gov>
References: <433C3C87.4040401@anl.gov><20050929213533.koygqlpb3hy8ogsg@home.staff.uni-marburg.de><433C43AE.5060709@anl.gov><20050929215204.85kt3qx0hwf4kc00@home.staff.uni-marburg.de><433C49F1.1010409@anl.gov> <433C4BE1.7000107@anl.gov> <20050929223150.81i91gujaqds8wk8@home.staff.uni-marburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EL6EI-0007xK-4c
	for nfs@lists.sourceforge.net; Thu, 29 Sep 2005 14:46:14 -0700
Received: from biomail.bio.anl.gov ([146.139.170.3])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EL6EF-0002wc-Ak
	for nfs@lists.sourceforge.net; Thu, 29 Sep 2005 14:46:14 -0700
To: Reuti <reuti@staff.uni-marburg.de>
In-Reply-To: <20050929223150.81i91gujaqds8wk8@home.staff.uni-marburg.de>
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

I've tried mounting it, and see that rpc.mountd performance is just over
3 times better. 

I notice that "df" doesn't show it, but "mount" does.  Now that I've got
it mounted, I get this:

    % mount | grep nfsd
    nfsd on /proc/fs/nfsd type nfsd (rw)

Now examining an strace of rpc.mountd.

-Brian


Reuti wrote:

> Yes, I als use v3. And there is no entry in "df" for this filesystem
> or so; if
> it is mounted in any of the scripts, to me it looks like you can check
> this
> only if there is anything inside /proc/fs/nfsd - then it's mounted.
>
> But anyway, if you modify the script just to test the other mode of
> nsfd (have a
> look at "man 8 exportfs" - and mountd is involved there), you could check
> whether there is any difference.
>
> -- Reuti
>
>
> Zitat von Brian Elliott Finley <finley@anl.gov>:
>
> > I've taken a quick look at your posts.  My situation is a bit different:
> >
> >    * Using nfs v3 only
> >    * /proc/fs/nfsd does exist, but it is not a mounted filesystem
> >    * stale filehandles and errors don't seem to be an issue, only
> >      rpc.mountd monopolizing CPU during client mounting
> >
> > Cheers, -Brian
> >
> >
> > Brian Elliott Finley wrote:
> >
> >> Reuti,
> >>
> >> /proc/fs/nfsd/ does exist.  I'll go back and have a look at your posts.
> >>
> >> -Brian
> >>
> >>
> >>
> >> Reuti wrote:
> >>
> >>
> >>
> >>> Typo: the one I meant was /proc/fs/nfsd - is there anything in this
> >>> directory?
> >>>
> >>> -- Reuti
> >>>
> >>> Zitat von Brian Elliott Finley <finley@anl.gov>:
> >>>
> >>>
> >>>
> >>>> Reuti,
> >>>>
> >>>> Thanks for your reply, but I'm afraid /proc/nfs/nfsd is *not*
> currently
> >>>> mounted.
> >>>>
> >>>> Cheers, -Brian
> >>>>
> >>>>
> >>>> Reuti wrote:
> >>>>
> >>>>
> >>>>
> >>>>> Brian,
> >>>>>
> >>>>> is there a file system mounted in /proc/nfs/nfsd - then nfsd is
> working
> >>>>> in a new
> >>>>> mode? You can try *not* to mount it in the start/stop-script of
> the NFS
> >>>>> server.
> >>>>> This way you will force nsfd to operate in a legacy mode. If you
> >>>>> followed my
> >>>>> posts last week, this solved a problem with stale file handles
> for me.
> >>>>>
> >>>>> Cheers - Reuti
> >>>>>
> >>>>>
> >>>>> Zitat von Brian Elliott Finley <finley@anl.gov>:
> >>>>>
> >>>>>
> >>>>>
> >>>>>> I've got an nfs server (quad cpu amd64, 36G mem, failover
> >>>>>>
> >>>>>>
> >>> fiberchannel)
> >>>
> >>>
> >>>>>> running ubuntu, and I'm getting the following behavior that I
> haven't
> >>>>>> been able to track down yet:
> >>>>>>
> >>>>>>   * rpc.mountd spikes to 99% cpu usage when a client machine
> mounts,
> >>>>>>     causing a temporary disruption in service to all client systems
> >>>>>>
> >>>>>> Google, NFS Howtos, NFS Perf Tuning docs, IRC (can't find an NFS
> >>>>>> specific IRC channel), local sysadmins all turn up nothing so
> >>>>>>
> >>>>>>
> >>> far.  Here
> >>>
> >>>
> >>>>>> are potentially relavant data:
> >>>>>>
> >>>>>>   * exportfs -v -o rw,secure,sync,no_root_squash
> >>>>>>     10.10.0.0/255.255.0.0:/export/home
> >>>>>>   * nfs server has all clients info in /etc/hosts
> >>>>>>   * /etc/hosts is first in nsswitch.conf
> >>>>>>   * kernel is ubuntu's: linux-image-2.6.10-5-amd64-k8-smp
> >>>>>>   * nfs performance is fine once a filesystem is mounted
> >>>>>>   * unless, someone else is mounting a filesystem, in which case
> >>>>>>     already mounted filesystems
> >>>>>>   * only 8 clients
> >>>>>>   * home directories mounted by autofs on clients as
> >>>>>>     server:/export/home/bob /home/bob
> >>>>>>   * 32 nfsd threads
> >>>>>>   * % netstat -in
> >>>>>>     Kernel Interface table
> >>>>>>     Iface   MTU Met   RX-OK RX-ERR RX-DRP RX-OVR   TX-OK TX-ERR
> >>>>>>
> >>>>>>
> >>> TX-DRP
> >>>
> >>>
> >>>>>>     TX-OVR Flg
> >>>>>>     eth0   1500 0  247854230      0      0      0324570001      0
> >>>>>>     0      0 BMRU
> >>>>>>     eth1   1500 0  1022171197      0      0      0258643880
> >>>>>>     0      0      0 BMR U
> >>>>>>     lo    16436 0    419024      0      0      0  419024      0
> >>>>>>     0      0 LRU
> >>>>>>   * % cat /proc/net/rpc/nfsd | grep ^th
> >>>>>>     th 32 8229 13759.142 6537.314 1919.479 4.212 129.977 52.636
> >>>>>>
> >>>>>>
> >>> 11.780
> >>>
> >>>
> >>>>>>     10.231 0.000 101.321
> >>>>>>   * caching bind9 installed on server, and it points to itself for
> >>>>>>     first nameserver entry
> >>>>>>
> >>>>>> Any one know what's up here?  Or how I can tell what's making
> >>>>>>
> >>>>>>
> >>> rpc.mountd
> >>>
> >>>
> >>>>>> take so much time?
> >>>>>>
> >>>>>> --
> >>>>>> Brian Elliott Finley
> >>>>>> Linux Strategist, CIS
> >>>>>> Desk: 630.252.4742
> >>>>>> Cell: 630.631.6621
> >>>>>>
> >>>>>>
> >>>>>>
> >>>>>> -------------------------------------------------------
> >>>>>> This SF.Net email is sponsored by:
> >>>>>> Power Architecture Resource Center: Free content, downloads,
> >>>>>>
> >>>>>>
> >>>>> discussions,
> >>>>>
> >>>>>
> >>>>>> and more. http://solutions.newsforge.com/ibmarch.tmpl
> >>>>>> _______________________________________________
> >>>>>> NFS maillist  -  NFS@lists.sourceforge.net
> >>>>>> https://lists.sourceforge.net/lists/listinfo/nfs
> >>>>>>
> >>>>>>
> >>>>>>
> >>>>>
> >>>>>
> >>>>>
> >>>>> -------------------------------------------------------
> >>>>> This SF.Net email is sponsored by:
> >>>>> Power Architecture Resource Center: Free content, downloads,
> >>>>>
> >>>>>
> >>> discussions,
> >>>
> >>>
> >>>>> and more. http://solutions.newsforge.com/ibmarch.tmpl
> >>>>> _______________________________________________
> >>>>> NFS maillist  -  NFS@lists.sourceforge.net
> >>>>> https://lists.sourceforge.net/lists/listinfo/nfs
> >>>>>
> >>>>>
> >>>>>
> >>>> --
> >>>> Brian Elliott Finley
> >>>> Linux Strategist, CIS
> >>>> Desk: 630.252.4742
> >>>> Cell: 630.631.6621
> >>>>
> >>>>
> >>>>
> >>>> -------------------------------------------------------
> >>>> This SF.Net email is sponsored by:
> >>>> Power Architecture Resource Center: Free content, downloads,
> >>>>
> >>>>
> >>> discussions,
> >>>
> >>>
> >>>> and more. http://solutions.newsforge.com/ibmarch.tmpl
> >>>> _______________________________________________
> >>>> NFS maillist  -  NFS@lists.sourceforge.net
> >>>> https://lists.sourceforge.net/lists/listinfo/nfs
> >>>>
> >>>>
> >>>>
> >>
> >>
> >>
> >
> > --
> > Brian Elliott Finley
> > Linux Strategist, CIS
> > Desk: 630.252.4742
> > Cell: 630.631.6621
> >
> >
> >
> > -------------------------------------------------------
> > This SF.Net email is sponsored by:
> > Power Architecture Resource Center: Free content, downloads,
> discussions,
> > and more. http://solutions.newsforge.com/ibmarch.tmpl
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >
>

-- 
Brian Elliott Finley
Linux Strategist, CIS
Desk: 630.252.4742
Cell: 630.631.6621



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
