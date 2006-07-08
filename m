From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH] Fix NFS mount options in mount.nfs
Date: Sat, 8 Jul 2006 14:56:37 -0400
Message-ID: <76bd70e30607081156u75d8bd28oda7432eab6d82c5d@mail.gmail.com>
References: <44AE9DC7.4050606@redhat.com> <20060707174542.GA2953@uio.no>
	<44AEA1FE.6080402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Steve Dickson <SteveD@redhat.com>,
	"Steinar H. Gunderson" <sesse@debian.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FzHyq-00053G-Ui
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 11:56:41 -0700
Received: from nf-out-0910.google.com ([64.233.182.186])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FzHyq-0002VT-1q
	for nfs@lists.sourceforge.net; Sat, 08 Jul 2006 11:56:41 -0700
Received: by nf-out-0910.google.com with SMTP id b2so223285nfe
	for <nfs@lists.sourceforge.net>; Sat, 08 Jul 2006 11:56:37 -0700 (PDT)
To: "Amit Gud" <agud@redhat.com>
In-Reply-To: <44AEA1FE.6080402@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 7/7/06, Amit Gud <agud@redhat.com> wrote:
> Steinar H. Gunderson wrote:
> > Thanks, that should clean up most of the problems. How well is this tested?
> >
>
> The problem was the options that are meant solely for the mount utility,
> like remount or noauto, were being passed further down to the syscall.
> These options should be handled within the mount utility only and should
> not be passed further.
>
> I tested with options like
> noauto,async,_netdev,nodiratime,users,dirsync,noatime,nodev,mand,group,owner,suid,user,exec,rw,soft,intr
> and it apparently worked OK. This isn't regressively tested though. I
> would like to see this patch tested in the environment mentioned in
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=376839 .

How does this change affect the mount options that show up in
/proc/mounts and /proc/self/mountstats?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
