From: Gcc k6 testing account <caligula@cam029208.student.utwente.nl>
Subject: Re: 2.5.32 bootfailure for nfsroot
Date: Fri, 27 Sep 2002 17:43:02 +0200 (CEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0209271729230.26871-100000@cam029208.student.utwente.nl>
References: <200209271239.g8RCdIp09188@Port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200209271239.g8RCdIp09188@Port.imtp.ilyichevsk.odessa.ua>
List-ID: <nfs.lists.sourceforge.net>

On Fri, 27 Sep 2002, Denis Vlasenko wrote:

> > > The subject says it all.
> > > 2.5.32 doesn't boot when using nfsroot.
> > > same systems running fine with 2.4.19/2.5.31
> > >
> > > SYSTEMS:
> > >    athlon with/without preempt. (flatbak)
> > >    i586 with preempt.           (cam029205)
> > >
> > > The relevant configs/dmesg/lspci are on
> > > cam029208.student.utwente.nl/~caligula.
> > >
> > > SYMPTOMS:
> > > I'm using loadlin to load the kernels. I see the kernel loading,unzipping
> > > and then...black screen followed by reboot.
> >
> > Small update.
> > Still no joy with 2.5.33. Same results,same symptoms :(
> 
> Why do you think it is nfsroot related?
> Does it boot off local filesystem?
> --
> vda
> 


Well, it was a guess. And a very wrong one too,it appeard later on.

After I posted the message and got no reaction,I tried some different 
kernel configs,and finally a very lean one.  No preempt,i386 only,no 
mtrr,no ide,no nfsroot. The idea was let the kernel boot,and then 
let it complain  it can't find a rootsystem. Even that wouldn't work.
Same symptoms. Loadlin unzapping kernel and than whush...black screen 
followed by reboot.

A very lean kernel >2.5.32 won't boot with loadlin on my system.
So no relation to nfsroot (my mistake).

So my GUESS is,it has something to do with the interaction between loadlin 
and the kernel.

Greetz Mu



 
