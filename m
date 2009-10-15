From: Ondrej Valousek <webserv-K2D8ygZuxnnrBKCeMvbIDA@public.gmane.org>
Subject: Re: [NFS] mount nfs4 w/krb5 on CentOS 4.x
Date: Thu, 15 Oct 2009 09:20:46 +0200
Message-ID: <4AD6CD4E.10009__5414.30199887163$1255594722$gmane$org@s3group.cz>
References: <20091014192438.GA7843@sewage>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: Matt Garman <matthew.garman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45882 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761693AbZJOIAe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Oct 2009 04:00:34 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1MyLFc-0003XX-TD
	for linux-nfs@vger.kernel.org; Thu, 15 Oct 2009 18:59:56 +1100
In-Reply-To: <20091014192438.GA7843@sewage>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Basically, I have never tried this with RHEL-4 and I would not recommend 
you it either as NFSv4 in RHEL-4 seems to be quite unstable and might 
cause your machine to crash with kernel panic. I would recommend 
RHEL/CentOS 5 for this kind of test.

If you want to pursue it anyway, turn on debugging of rpc.svcgssd 
(server) and rpc.gssd on the client - it will tell you more.

Ondrej


Matt Garman wrote:
> I am trying to deploy Kerberos-authenticated NFSv4 on CentOS 4.x
> (basically, RHEL4).
>
> For the most part, I've followed this document:
>
>     http://www.itp.uzh.ch/~dpotter/howto/kerberos
>
> Except that I ignored the LDAP stuff (which I don't need, only
> krb5+nfs4).  Here's what happens when I try to mount:
>
>     # mount -v -t nfs4 -o sec=krb5 192.168.187.75:/share mnt
>     mount: pinging: prog 100003 vers 4 prot tcp port 2049
>     mount: block device 192.168.187.75:/share is write-protected,
>     mounting read-only
>     mount: pinging: prog 100003 vers 4 prot tcp port 2049
>     mount: cannot mount block device 192.168.187.75:/share read-only
>
> There is no firewall running on any of the machines.
>
> Here is the /etc/exports file on 192.168.187.75:
>
>     /export gss/krb5(sync,rw,fsid=0,insecure,no_subtree_check,anonuid=65534,anongid=65534)
>     /export/share gss/krb5(sync,rw,nohide,insecure,no_subtree_check,anonuid=65534,anongid=65534)
>
> Here is what rpcinfo shows:
>
>     # rpcinfo -p 192.168.187.75
>        program vers proto   port
>         100000    2   tcp    111  portmapper
>         100000    2   udp    111  portmapper
>         100024    1   udp    697  status
>         100024    1   tcp    700  status
>         100011    1   udp    864  rquotad
>         100011    2   udp    864  rquotad
>         100011    1   tcp    867  rquotad
>         100011    2   tcp    867  rquotad
>         100003    2   udp   2049  nfs
>         100003    3   udp   2049  nfs
>         100003    4   udp   2049  nfs
>         100003    2   tcp   2049  nfs
>         100003    3   tcp   2049  nfs
>         100003    4   tcp   2049  nfs
>         100021    1   udp  32778  nlockmgr
>         100021    3   udp  32778  nlockmgr
>         100021    4   udp  32778  nlockmgr
>         100021    1   tcp  35837  nlockmgr
>         100021    3   tcp  35837  nlockmgr
>         100021    4   tcp  35837  nlockmgr
>         100005    1   udp    880  mountd
>         100005    1   tcp    883  mountd
>         100005    2   udp    880  mountd
>         100005    2   tcp    883  mountd
>         100005    3   udp    880  mountd
>         100005    3   tcp    883  mountd
>
> Both the server and the client have NFSv4 capability according to
> "fgrep nfs4 /proc/kallsyms" (well, at least running that command
> returned 240 lines).
>
> If I try to execute that same mount command on the server
> (192.168.187.75) itself, I get:
>
>     # mount -v -t nfs4 -o sec=krb5 192.168.187.75:/share mnttmp/
>     Warning: rpc.gssd appears not to be running.
>     mount: pinging: prog 100003 vers 4 prot tcp port 2049
>
> And then it hangs.  Literally forever: None of Ctrl-C, Ctrl-Z, or
> kill -9 will stop the program.
>
> One note: the page I linked above has this note:
>
>     "NFSv4 using Kerberos authentication in RHEL4 seems to be broken
>      with the latest patch level. When I find a solution it will be
>      posted here. LDAP and Kerberos for authentication of users
>      works fine."
>
> Since the document hasn't been updated for over a year, I was hoping
> this note was obsolete... but even if it is still true (which it may
> well be), it doesn't say which component causes the breakage (e.g.
> kernel, kerberos, nfs-utils, etc).  In other words, can I just
> recompile a newer version of a package or two to get around any
> RHEL4/CentOS4 breakages?
>
> If anyone is willing to provide some hand-holding, it would be much
> appreciated!
>
> Thank you,
> Matt
>
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
>   


------------------------------------------------------------------------------
Come build with us! The BlackBerry(R) Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9 - 12, 2009. Register now!
http://p.sf.net/sfu/devconference
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

