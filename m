From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: 2.5.32 bootfailure for nfsroot
Date: Fri, 27 Sep 2002 15:33:32 -0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200209271239.g8RCdIp09188@Port.imtp.ilyichevsk.odessa.ua>
References: <Pine.LNX.4.44.0209021041260.30980-100000@cam029208.student.utwente.nl>
Reply-To: vda@port.imtp.ilyichevsk.odessa.ua
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Gcc k6 testing account <caligula@cam029208.student.utwente.nl>,
	linux-kernel@vger.kernel.org
In-Reply-To: <Pine.LNX.4.44.0209021041260.30980-100000@cam029208.student.utwente.nl>
List-ID: <nfs.lists.sourceforge.net>

> > The subject says it all.
> > 2.5.32 doesn't boot when using nfsroot.
> > same systems running fine with 2.4.19/2.5.31
> >
> > SYSTEMS:
> >    athlon with/without preempt. (flatbak)
> >    i586 with preempt.           (cam029205)
> >
> > The relevant configs/dmesg/lspci are on
> > cam029208.student.utwente.nl/~caligula.
> >
> > SYMPTOMS:
> > I'm using loadlin to load the kernels. I see the kernel loading,unzipping
> > and then...black screen followed by reboot.
>
> Small update.
> Still no joy with 2.5.33. Same results,same symptoms :(

Why do you think it is nfsroot related?
Does it boot off local filesystem?
--
vda
