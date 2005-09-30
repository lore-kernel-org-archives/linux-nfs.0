From: Brian Elliott Finley <finley@anl.gov>
Subject: Re: rpc.mountd at 99% cpu
Date: Fri, 30 Sep 2005 16:41:18 -0500
Message-ID: <433DB0FE.7070808@anl.gov>
References: <433C3C87.4040401@anl.gov><20050929213533.koygqlpb3hy8ogsg@home.staff.uni-marburg.de><433C43AE.5060709@anl.gov><20050929215204.85kt3qx0hwf4kc00@home.staff.uni-marburg.de><433C49F1.1010409@anl.gov> <433C4BE1.7000107@anl.gov> <20050929223150.81i91gujaqds8wk8@home.staff.uni-marburg.de> <433C60AF.30409@anl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Reuti <reuti@staff.uni-marburg.de>,
	Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ELWUH-0002tH-3U
	for nfs@lists.sourceforge.net; Fri, 30 Sep 2005 18:48:29 -0700
Received: from peabody.anl.gov ([146.137.222.62] helo=anlmail.anl.gov)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ELSd3-00005G-Fc
	for nfs@lists.sourceforge.net; Fri, 30 Sep 2005 14:41:25 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <433C60AF.30409@anl.gov>
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

Reuti, Dan,

I've resolved my problem, and I think I've solved it too.

The following details my process and result, in the hope that it may
benefit others.  Thanks to Dan and Reuti for their help.

Cheers, -Brian


<<<<<<<<<<>>>>>>>>>>

NFS Server Performance Troubleshooting
--------------------------------------
#
# 2005.09.30 Brian Elliott Finley
#

Problem:
    - Poor performance in general
    - Sometimes home directories not mounted on clients
    - Bursty performance -- sometimes good, sometimes bad
    - Performance got so bad at one point that nfs server service had to be
        restarted.

Initial Observations:
    rpc.mountd and/or nfsd sometimes taking 99% of one CPU
   
Initial Tuning:
    /etc/default/nfs-kernel-server: s/RPCNFSDCOUNT=8/RPCNFSDCOUNT=32/
        See: http://nfs.sourceforge.net/nfs-howto/performance.html
            (section 5.6)
   
Further Observations:
    rpc.mountd, nfsd, and ypserv (sometimes) tend to spike when a mount
        request happens.
    Timeouts in auto.master are set to 10s for 3 maps, and 160s for one
        map, so mount requests happen very often.  The autofs default
        timeout is 5m (300).
    Some entries in /etc/exports use hostnames, some use IP addresses
        (herring or no?)
    client1 using these ext3 mount options: noatime,data=writeback.  nfs01
        not using these.
    client1 using async nfs exports (nfs-utils-0.3.1-14.72).  The default
        export behavior for both NFS Version 2 and Version 3 protocols,
        used by exportfs in nfs-utils versions prior to nfs-utils-1.0.1
        is "asynchronous".  See:
        http://nfs.sourceforge.net/nfs-howto/performance.html (section
        5.9).  nfs01 using synchronous Writes (nfs-kernel-server
        1.0.6-3.1ubuntu1).
   
   
Second Level Tuning:
    1.) Modify ext3 mount options to include noatime, and mount -o remount
        each file system.  No casually noticeable improvement.

    2.) Try s/sync/async/ nfs01:/etc/exports for /export/home filesystem,
        then re-export.  No casually noticeable improvement.  Changed
        back to sync.  async is technically non-NFS compliant.

    3.) Change all hostnames to IP addresses in /etc/exports, then
        re-export.  No casually noticeable imrovement.

    4.) Some hostnames, some IPs show up in /var/lib/nfs/etab, despite
        having only IPs listed in /etc/exports.  Tried this:
        "exportfs -v -o \
        rw,secure,sync,no_root_squash \
        10.10.0.0/255.255.0.0:/export/home"
        Then unexported everything else.  No improvement.

    5.) Used Ethereal to sniff the net -- no obvious issues there.  A
        re-transmit of a mount request, but that is likely due to slow
        response time of rpc.mountd rather than a network problem.

    6.) rpcinfo -p nfs01-priv.net.anl.gov from both nfs01, and from client
        side look fine.

    7.) No entries in /etc/hosts.{allow,deny} to get in the way.

    8.) All client IP/Hostname combos in /etc/hosts on nfs01, so lookup
        timeouts shouldn't be an issue, but tried commenting out nis on
        the hosts line in /etc/nsswitch.conf just in case.  No
        improvement.

    9.) Installed a bind9 daemon in a cacheing only config on nfs01, and
        modified /etc/resolv.conf to look to itself first when
        performing a DNS resolution.  No improvement.

    10.) Modified auto.master umount timeout, and upped it from 10s to just
        over 1h.  This significantly decreased the frequency of the
        disruptions, but didn't address the underlying problem.

    11.) Did this:  "mount -t nfsd nfsd /proc/fs/nfsd" to try the "new
        style" NFS for 2.6 series kernels.  Without this, NFS behaves
        like it's on a 2.4 series kernel.  There was no specific reason
        why this should cause an improvement, but it cut the following
        ls command (which forces an automount of the three
        filesystems in question) down from 30s to 7s.
       
        sudo umount /home/{user1,user2,user3}
        time ls -d /home/{user1,user2,user3}/.
       
    12.) strace -p $(pidof rpc.mountd) didn't reveal anything particularly
        odd, but it was done after /proc/fs/nfsd was mounted, and it did
        try to read /proc/fs/nfsd/filehandle.  I take this as further
        indication that mounting /proc/fs/nfsd/ was key.

    13.) client1 reboot determined necessary.  I took this opportunity to do
        a complete stop and restart of the NFS daemons and the
        portmapper.  Immediately upon a clean restart of these two (no
        changes had actually been made to anything that should affect
        portmap, but restarted it anyway just to get a perfectly clean
        slate) mount performance improved from the 7s to execute "time
        ls -d /home/{user1,user2,user3}/." down to 0.030s.
       
        Bingo!
   
    14.) I modified /etc/fstab to mount /proc/fs/nfsd on future boots.
       
Conclusion:
    Prior to Second Level Tuning step 13, the NFS daemons hadn't been
    restarted since the Initial Tuning, which only increased the number
    of nfsd threads.  This means that Second Level Tuning steps 1 - 12 were
    performed without a restart of the nfs daemons. 
   
    Which step was key?  Was it a combination of them?  Well, I can't
    say with 100% certainty without backstepping and restarting the nfs
    daemons each time, which obviously causes an service outage, but seeing
    as how step number 11 was the only step that provoked any kind of
    improvement prior to restarting the daemons, and was the only part of
    the configuration that was clearly expected to change behavior in a
    significant way (2.4 series kernel style behavior vs. 2.6 series kernel
    style behavior), my current theory is this:

        The mounting of /proc/fs/nfsd was key.  And while the mounting
        of it had an immediate effect for certain nfs daemon functions,
        it didn't have an immediate effect for others.  Once the nfs
        daemons were completely flushed    and restarted cleanly,
        it had an effect on all relevant nfs daemon functions.
   
   
       
       

Brian Elliott Finley wrote:

> I've tried mounting it, and see that rpc.mountd performance is just over
> 3 times better.
>
> I notice that "df" doesn't show it, but "mount" does.  Now that I've got
> it mounted, I get this:
>
>     % mount | grep nfsd
>     nfsd on /proc/fs/nfsd type nfsd (rw)
>
> Now examining an strace of rpc.mountd.
>
> -Brian
>
>
> Reuti wrote:
>
> > Yes, I als use v3. And there is no entry in "df" for this filesystem
> > or so; if
> > it is mounted in any of the scripts, to me it looks like you can check
> > this
> > only if there is anything inside /proc/fs/nfsd - then it's mounted.
> >
> > But anyway, if you modify the script just to test the other mode of
> > nsfd (have a
> > look at "man 8 exportfs" - and mountd is involved there), you could
> check
> > whether there is any difference.
> >
> > -- Reuti
> >
> >
> > Zitat von Brian Elliott Finley <finley@anl.gov>:
> >
> > > I've taken a quick look at your posts.  My situation is a bit
> different:
> > >
> > >    * Using nfs v3 only
> > >    * /proc/fs/nfsd does exist, but it is not a mounted filesystem
> > >    * stale filehandles and errors don't seem to be an issue, only
> > >      rpc.mountd monopolizing CPU during client mounting
> > >
> > > Cheers, -Brian
> > >
> > >
> > > Brian Elliott Finley wrote:
> > >
> > >> Reuti,
> > >>
> > >> /proc/fs/nfsd/ does exist.  I'll go back and have a look at your
> posts.
> > >>
> > >> -Brian
> > >>
> > >>
> > >>
> > >> Reuti wrote:
> > >>
> > >>
> > >>
> > >>> Typo: the one I meant was /proc/fs/nfsd - is there anything in this
> > >>> directory?
> > >>>
> > >>> -- Reuti
> > >>>
> > >>> Zitat von Brian Elliott Finley <finley@anl.gov>:
> > >>>
> > >>>
> > >>>
> > >>>> Reuti,
> > >>>>
> > >>>> Thanks for your reply, but I'm afraid /proc/nfs/nfsd is *not*
> > currently
> > >>>> mounted.
> > >>>>
> > >>>> Cheers, -Brian
> > >>>>
> > >>>>
> > >>>> Reuti wrote:
> > >>>>
> > >>>>
> > >>>>
> > >>>>> Brian,
> > >>>>>
> > >>>>> is there a file system mounted in /proc/nfs/nfsd - then nfsd is
> > working
> > >>>>> in a new
> > >>>>> mode? You can try *not* to mount it in the start/stop-script of
> > the NFS
> > >>>>> server.
> > >>>>> This way you will force nsfd to operate in a legacy mode. If you
> > >>>>> followed my
> > >>>>> posts last week, this solved a problem with stale file handles
> > for me.
> > >>>>>
> > >>>>> Cheers - Reuti
> > >>>>>
> > >>>>>
> > >>>>> Zitat von Brian Elliott Finley <finley@anl.gov>:
> > >>>>>
> > >>>>>
> > >>>>>
> > >>>>>> I've got an nfs server (quad cpu amd64, 36G mem, failover
> > >>>>>>
> > >>>>>>
> > >>> fiberchannel)
> > >>>
> > >>>
> > >>>>>> running ubuntu, and I'm getting the following behavior that I
> > haven't
> > >>>>>> been able to track down yet:
> > >>>>>>
> > >>>>>>   * rpc.mountd spikes to 99% cpu usage when a client machine
> > mounts,
> > >>>>>>     causing a temporary disruption in service to all client
> systems
> > >>>>>>
> > >>>>>> Google, NFS Howtos, NFS Perf Tuning docs, IRC (can't find an NFS
> > >>>>>> specific IRC channel), local sysadmins all turn up nothing so
> > >>>>>>
> > >>>>>>
> > >>> far.  Here
> > >>>
> > >>>
> > >>>>>> are potentially relavant data:
> > >>>>>>
> > >>>>>>   * exportfs -v -o rw,secure,sync,no_root_squash
> > >>>>>>     10.10.0.0/255.255.0.0:/export/home
> > >>>>>>   * nfs server has all clients info in /etc/hosts
> > >>>>>>   * /etc/hosts is first in nsswitch.conf
> > >>>>>>   * kernel is ubuntu's: linux-image-2.6.10-5-amd64-k8-smp
> > >>>>>>   * nfs performance is fine once a filesystem is mounted
> > >>>>>>   * unless, someone else is mounting a filesystem, in which case
> > >>>>>>     already mounted filesystems
> > >>>>>>   * only 8 clients
> > >>>>>>   * home directories mounted by autofs on clients as
> > >>>>>>     server:/export/home/bob /home/bob
> > >>>>>>   * 32 nfsd threads
> > >>>>>>   * % netstat -in
> > >>>>>>     Kernel Interface table
> > >>>>>>     Iface   MTU Met   RX-OK RX-ERR RX-DRP RX-OVR   TX-OK TX-ERR
> > >>>>>>
> > >>>>>>
> > >>> TX-DRP
> > >>>
> > >>>
> > >>>>>>     TX-OVR Flg
> > >>>>>>     eth0   1500 0  247854230      0      0      0324570001      0
> > >>>>>>     0      0 BMRU
> > >>>>>>     eth1   1500 0  1022171197      0      0      0258643880
> > >>>>>>     0      0      0 BMR U
> > >>>>>>     lo    16436 0    419024      0      0      0  419024      0
> > >>>>>>     0      0 LRU
> > >>>>>>   * % cat /proc/net/rpc/nfsd | grep ^th
> > >>>>>>     th 32 8229 13759.142 6537.314 1919.479 4.212 129.977 52.636
> > >>>>>>
> > >>>>>>
> > >>> 11.780
> > >>>
> > >>>
> > >>>>>>     10.231 0.000 101.321
> > >>>>>>   * caching bind9 installed on server, and it points to
> itself for
> > >>>>>>     first nameserver entry
> > >>>>>>
> > >>>>>> Any one know what's up here?  Or how I can tell what's making
> > >>>>>>
> > >>>>>>
> > >>> rpc.mountd
> > >>>
> > >>>
> > >>>>>> take so much time?
> > >>>>>>
> > >>>>>> --
> > >>>>>> Brian Elliott Finley
> > >>>>>> Linux Strategist, CIS
> > >>>>>> Desk: 630.252.4742
> > >>>>>> Cell: 630.631.6621
> > >>>>>>
> > >>>>>>
> > >>>>>>
> > >>>>>> -------------------------------------------------------
> > >>>>>> This SF.Net email is sponsored by:
> > >>>>>> Power Architecture Resource Center: Free content, downloads,
> > >>>>>>
> > >>>>>>
> > >>>>> discussions,
> > >>>>>
> > >>>>>
> > >>>>>> and more. http://solutions.newsforge.com/ibmarch.tmpl
> > >>>>>> _______________________________________________
> > >>>>>> NFS maillist  -  NFS@lists.sourceforge.net
> > >>>>>> https://lists.sourceforge.net/lists/listinfo/nfs
> > >>>>>>
> > >>>>>>
> > >>>>>>
> > >>>>>
> > >>>>>
> > >>>>>
> > >>>>> -------------------------------------------------------
> > >>>>> This SF.Net email is sponsored by:
> > >>>>> Power Architecture Resource Center: Free content, downloads,
> > >>>>>
> > >>>>>
> > >>> discussions,
> > >>>
> > >>>
> > >>>>> and more. http://solutions.newsforge.com/ibmarch.tmpl
> > >>>>> _______________________________________________
> > >>>>> NFS maillist  -  NFS@lists.sourceforge.net
> > >>>>> https://lists.sourceforge.net/lists/listinfo/nfs
> > >>>>>
> > >>>>>
> > >>>>>
> > >>>> --
> > >>>> Brian Elliott Finley
> > >>>> Linux Strategist, CIS
> > >>>> Desk: 630.252.4742
> > >>>> Cell: 630.631.6621
> > >>>>
> > >>>>
> > >>>>
> > >>>> -------------------------------------------------------
> > >>>> This SF.Net email is sponsored by:
> > >>>> Power Architecture Resource Center: Free content, downloads,
> > >>>>
> > >>>>
> > >>> discussions,
> > >>>
> > >>>
> > >>>> and more. http://solutions.newsforge.com/ibmarch.tmpl
> > >>>> _______________________________________________
> > >>>> NFS maillist  -  NFS@lists.sourceforge.net
> > >>>> https://lists.sourceforge.net/lists/listinfo/nfs
> > >>>>
> > >>>>
> > >>>>
> > >>
> > >>
> > >>
> > >
> > > --
> > > Brian Elliott Finley
> > > Linux Strategist, CIS
> > > Desk: 630.252.4742
> > > Cell: 630.631.6621
> > >
> > >
> > >
> > > -------------------------------------------------------
> > > This SF.Net email is sponsored by:
> > > Power Architecture Resource Center: Free content, downloads,
> > discussions,
> > > and more. http://solutions.newsforge.com/ibmarch.tmpl
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > >
> >
>
> --
> Brian Elliott Finley
> Linux Strategist, CIS
> Desk: 630.252.4742
> Cell: 630.631.6621
>
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by:
> Power Architecture Resource Center: Free content, downloads, discussions,
> and more. http://solutions.newsforge.com/ibmarch.tmpl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
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
