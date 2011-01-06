Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13369 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751649Ab1AFWBP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Jan 2011 17:01:15 -0500
Subject: RE: [nfsv4] Questions on pNFS
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: david.noveck@emc.com
Cc: bhalevy@panasas.com, wolf0805@163.com, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
In-Reply-To: <BF3BB6D12298F54B89C8DCC1E4073D8002C47E40@CORPUSMX50A.corp.emc.com>
References: <4D0E2E01.5020609@panasas.com>
	 ,<fed0592.55ef.12cfee2b158.Coremail.wolf0805@163.com>
	 ,<18c0c0f3.1adea.12d0e4252bd.Coremail.wolf0805@163.com>
	 <201012301048485665083@163.com> <4D21D71D.8030907@panasas.com>
	 <BF3BB6D12298F54B89C8DCC1E4073D8002C47E40@CORPUSMX50A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 06 Jan 2011 17:00:54 -0500
Message-ID: <1294351254.3164.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-06 at 16:20 -0500, david.noveck@emc.com wrote: 
> I'm very confused by this interchange.
> 
> > > I found there wasn't any byte-range lock as specified in the ietf-nfsv4-draft protocol.
> 
> > Correct.
> 
> Huh?
> 
> The nfsv4 protocol does have byte-range locks.  It is optional whether they are advisory or mandatory, but they do exist.
> 
> Could Benny mean that they don't work in his server?  It doesn't seem so because he advises Zhangyu to use locking. 
> 
> The only form of mandatory locking in NFSv4 are share reservations.  Waiting to edit your file may be drag but it is better than turning it into a mess.

There is at least one storage vendor that actually sells a server that
implements NFSv4 mandatory byte range locking. ;-)

> I've never seen an editor that allowed multiple users to edit a file and used byte-range locks to synchronize.  It seems like a fun project as long as there was no delivery schedule.

Perhaps Yu is referring to the section concerning how to deal with
NFS4ERR_LOCKED messages?

It is true that we currently do not attempt to automatically recover if
mandatory locking is supported, and the range we're trying to access is
locked. To me, that sort of situation really needs to be fixed by
changing the application that is failing to lock. The kernel and NFS
client does not have enough information to know what kind of application
races the lock is supposed to be protecting against...

Cheers
  Trond


> -----Original Message-----
> From: nfsv4-bounces@ietf.org [mailto:nfsv4-bounces@ietf.org] On Behalf Of Benny Halevy
> Sent: Monday, January 03, 2011 9:03 AM
> To: Zhangyu
> Cc: linux-nfs; nfsv4
> Subject: Re: [nfsv4] Questions on pNFS
> 
> [trimmed mailing lists on the Cc]
> 
> On 2010-12-30 04:48, Zhangyu wrote:
> > Hi,
> > 
> > I have successfully installed the pNFS and it works well.
> 
> Great!
> 
> > However, I am interested in the parallel access control mechanism of pNFS.
> > I tried to edit the same file on two different clients,
> > I found there wasn't any byte-range lock as specified in the ietf-nfsv4-draft protocol.
> 
> Correct.
> 
> > How is the parallel access control implemented? Which source code file does it located in? 
> > 
> 
> There is none by definition.
> The pNFS feature is orthogonal to synchronization primitives so
> different clients that need to serialize their access should use locking
> to do that.
> 
> Some servers may implement synchronization at the pnfs layout level,
> but the linux server has no such feature.
> 
> > Additionally, I found that when writing a file to the DS, network flow is higher both
> > on MDS and DS. Does it mean that the data is delivered through MDS?
> > I think the data should be written directly to DS, is it right?
> 
> True.  If your setup is configured correctly there should be no
> I/O directed at the MDS.
> Can you capture a network trace to the MDS and to the DS to see what exactly
> is sent on the line?
> 
> Benny
> 
> > 
> > Thanks & Regards,
> > Yu Zhang 
> > 
> > 2010-12-30 
> > 
> > 
> > 
> > Zhangyu 
> > 
> > 
> > 
> > 发件人： Benny Halevy 
> > 发送时间： 2010-12-26  16:27:55 
> > 收件人： wolf0805 
> > 抄送： NFS list 
> > 主题： Re: Errors on pNFS 
> >  
> > [Adding the linux-nfs mailing list to the Cc
> > please keep the folks on the list posted as they are interested
> > in the issues you encounter as well as the solutions]
> > On 2010-12-22 15:26, wolf0805 wrote:
> >> Hi Benny,
> >>
> >> I have installed pNFS kernel and pnfs-nfs-utils on three machines(client,mds,ds).
> >> But when I tried to load the layoutdriver, it gives error : "Fatal - module nfslayoutdriver not found."
> > Sorry, the layout driver was renamed to nfs_layout_nfsv41_files.
> > I've updated http://wiki.linux-nfs.org/wiki/index.php/Configuring_pNFS/spnfsd
> > to reflect that.
> > Benny
> >> I am using Fedora 14 with the uname -a saying "Linux localhost.localdomain 
> >> 2.6.36-1.pnfs_all_2010_11_03.fc15.i686.PAE #1 SMP Tue Nov 9 18:32:20 UTC 2010 i686 i686 i386 GNU/Linux".
> >> It seems the kernel is pnfs enabled, but where is the problem?
> >>
> >> The ds ip-addr is XX.YY.ZZ.AA, mds's is XX.YY.ZZ.BB, and client's is XX.YY.ZZ.CC. 
> >>
> >> The /etc/exports on ds looks as: /export/spnfs *(rw,sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_squash)
> >>
> >> The /etc/exports on mds : /export *(rw,sync,fsid=0,insecure,no_subtree_check,pnfs,no_root_!
> >>  squash)
> >>
> >> /etc/fstab on mds:  XX.YY.ZZ.AA:/       /spnfs/XX.YY.ZZ.A   nfs4    minorversion=1        0 0
> >>
> >> Then I mounted MDS from client using : mount -t nfs4 -o minorversion=1 XX.YY.ZZ.BB:/ /mnt
> >>
> >> I found that only mds and client are mounted, it seems ds is left alone. Is there any mistakes in these configure files? 
> >>
> >> I hope these helps.
> >>
> >> Best regards,
> >>
> >> Yu Zhang
> >>
> >>
> >>
> > .
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

