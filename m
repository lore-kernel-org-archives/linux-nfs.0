From: "Chakri n" <chakriin5@gmail.com>
Subject: Re: OOPS in shrink_dcache_for_umount
Date: Sun, 5 Aug 2007 09:39:15 -0700
Message-ID: <92cbf19b0708050939r6164474di64949e4044691951@mail.gmail.com>
References: <92cbf19b0708021427l7c88c642g3901e393ac2b90b9@mail.gmail.com>
	<20070804120105.47ae82fc@highlander.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "=?ISO-8859-1?Q?Malte_Schr=F6der?=" <maltesch@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IHj8L-0003EH-Qv
	for nfs@lists.sourceforge.net; Sun, 05 Aug 2007 09:39:16 -0700
Received: from wa-out-1112.google.com ([209.85.146.181])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IHj8O-0000wg-OT
	for nfs@lists.sourceforge.net; Sun, 05 Aug 2007 09:39:18 -0700
Received: by wa-out-1112.google.com with SMTP id k22so1667811waf
	for <nfs@lists.sourceforge.net>; Sun, 05 Aug 2007 09:39:16 -0700 (PDT)
In-Reply-To: <20070804120105.47ae82fc@highlander.home.lan>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Malte,

Thanks for the information.

Based on your suggestion I tried the following two patches on top of
2.6.18-1.8.el5 NFS code. I had to keep the changes minimum to fix this
crash in our release.

http://linux-nfs.org/Linux-2.6.x/2.6.20-rc7/linux-2.6.20-007-fix_readdir_ne=
gative_dentry.dif
http://linux-nfs.org/Linux-2.6.x/2.6.20-rc7/linux-2.6.20-008-fix_readdir_po=
sitive_dentry.dif

The systems are running for the past 7 hours with out any issues.
Hopefully this fixes it.

Regards
--Chakri

On 8/4/07, Malte Schr=F6der <maltesch@gmx.de> wrote:
> On Thu, 2 Aug 2007 14:27:04 -0700
> "Chakri n" <chakriin5@gmail.com> wrote:
>
> > Hi,
> >
> > We are seeing this problem while unmounting file systems. It happens
> > once in a while.
> > I am able to grab the trace and core from linux-2.6.18-1.8.el5, but I
> > have observed the same problem with linux-2.6.20.1 kernel.
> >
> > Has this problem fixed in recent kernel?
> >
>
> I had those too ... but I haven't seen one in a while.
> I currently run 2.6.22 + cfs-v19 + the Patch from
> http://linux-nfs.org/Linux-2.6.x/2.6.22/linux-2.6.22-NFS_ALL.dif
>
> --
> ---------------------------------------
> Malte Schr=F6der
> MalteSch@gmx.de
> ICQ# 68121508
> ---------------------------------------
>
>
>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
