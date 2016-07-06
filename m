Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56704 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbcGFAiX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jul 2016 20:38:23 -0400
Date: Tue, 5 Jul 2016 20:38:22 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Marc Eshel <eshel@us.ibm.com>
Cc: linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
Subject: Re: grace period
Message-ID: <20160706003822.GA14600@fieldses.org>
References: <20160701160857.GB20327@fieldses.org>
 <OF82A5FFDC.3CCEBF40-ON88257FE3.0059C174-88257FE3.00604E03@notes.na.collabserv.com>
 <20160701200742.GA24269@fieldses.org>
 <OF5D486F02.62CECB7B-ON88257FE3.0071DBE5-88257FE3.00722388@notes.na.collabserv.com>
 <20160701210151.GE24269@fieldses.org>
 <OF79A36FEE.749D5EF5-ON88257FE3.007C9721-88257FE3.007CC2B1@notes.na.collabserv.com>
 <20160702005820.GA27063@fieldses.org>
 <OFC1237E53.3CFCA8E8-ON88257FE5.001D3182-88257FE5.001E3AE3@notes.na.collabserv.com>
 <20160705205130.GA12351@fieldses.org>
 <OF9CFDF514.E5B5F6CB-ON88257FE7.007EA497-88257FE7.007EE256@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF9CFDF514.E5B5F6CB-ON88257FE7.007EA497-88257FE7.007EE256@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 05, 2016 at 04:05:56PM -0700, Marc Eshel wrote:
> Can you please point me to the kernel that you are using so I can check if 
> it is an obvious problem before I open an RHEL bug?

I've tried it on the latest upstream and on rhel 3.10.0-327.13.1.el7.

--b.

> Thanks, Marc. 
> 
> 
> 
> From:   Bruce Fields <bfields@fieldses.org>
> To:     Marc Eshel/Almaden/IBM@IBMUS
> Cc:     linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
> Date:   07/05/2016 01:52 PM
> Subject:        Re: grace period
> Sent by:        linux-nfs-owner@vger.kernel.org
> 
> 
> 
> On Sat, Jul 02, 2016 at 10:30:11PM -0700, Marc Eshel wrote:
> > I tried again NFSv3 locks with xfs export. "echo 0 > 
> > /proc/fs/nfsd/threads" releases locks on rhel7.0 but not on rhel7.2
> > What else can I show you to find the problem?
> 
> Sorry, I can't reproduce, though I've only tried a slightly later kernel
> than that.  Could you submit a RHEL bug?
> 
> --b.
> 
> > Marc.
> > 
> > works:
> > [root@boar11 ~]# uname -a
> > Linux boar11 3.10.0-123.el7.x86_64 #1 SMP Mon May 5 11:16:57 EDT 2014 
> > x86_64 x86_64 x86_64 GNU/Linux
> > [root@boar11 ~]# cat /etc/redhat-release 
> > Red Hat Enterprise Linux Server release 7.0 (Maipo)
> > 
> > not working:
> > [root@sonascl21 ~]# uname -a
> > Linux sonascl21.sonasad.almaden.ibm.com 3.10.0-327.el7.x86_64 #1 SMP Thu 
> 
> > Oct 29 17:29:29 EDT 2015 x86_64 x86_64 x86_64 GNU/Linux
> > [root@sonascl21 ~]# cat /etc/redhat-release 
> > Red Hat Enterprise Linux Server release 7.2 (Maipo)
> > [root@sonascl21 ~]# cat /proc/fs/nfsd/threads 
> > 0
> > [root@sonascl21 ~]# cat /proc/locks
> > 1: POSIX  ADVISORY  WRITE 2346 fd:00:1612092569 0 9999
> > 
> > 
> > 
> > From:   Bruce Fields <bfields@fieldses.org>
> > To:     Marc Eshel/Almaden/IBM@IBMUS
> > Cc:     linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
> > Date:   07/01/2016 05:58 PM
> > Subject:        Re: grace period
> > 
> > 
> > 
> > On Fri, Jul 01, 2016 at 03:42:43PM -0700, Marc Eshel wrote:
> > > Yes, the locks are requested from another node, what fs are you using, 
> I 
> > 
> > > don't think it should make any difference, but I can try it with the 
> > same 
> > > fs. 
> > > Make sure you are using v3, it does work for v4.
> > 
> > I tested v3 on upstream.--b.
> > 
> > > Marc.
> > > 
> > > 
> > > 
> > > From:   Bruce Fields <bfields@fieldses.org>
> > > To:     Marc Eshel/Almaden/IBM@IBMUS
> > > Cc:     linux-nfs@vger.kernel.org, Tomer Perry <TOMP@il.ibm.com>
> > > Date:   07/01/2016 02:01 PM
> > > Subject:        Re: grace period
> > > 
> > > 
> > > 
> > > On Fri, Jul 01, 2016 at 01:46:42PM -0700, Marc Eshel wrote:
> > > > This is my v3 test that show the lock still there after echo 0 > 
> > > > /proc/fs/nfsd/threads
> > > > 
> > > > [root@sonascl21 ~]# cat /etc/redhat-release 
> > > > Red Hat Enterprise Linux Server release 7.2 (Maipo)
> > > > 
> > > > [root@sonascl21 ~]# uname -a
> > > > Linux sonascl21.sonasad.almaden.ibm.com 3.10.0-327.el7.x86_64 #1 SMP 
> 
> > Thu 
> > > 
> > > > Oct 29 17:29:29 EDT 2015 x86_64 x86_64 x86_64 GNU/Linux
> > > > 
> > > > [root@sonascl21 ~]# cat /proc/locks | grep 999
> > > > 3: POSIX  ADVISORY  WRITE 2349 00:2a:489486 0 999
> > > > 
> > > > [root@sonascl21 ~]# echo 0 > /proc/fs/nfsd/threads
> > > > [root@sonascl21 ~]# cat /proc/fs/nfsd/threads
> > > > 0
> > > > 
> > > > [root@sonascl21 ~]# cat /proc/locks | grep 999
> > > > 3: POSIX  ADVISORY  WRITE 2349 00:2a:489486 0 999
> > > 
> > > Huh, that's not what I see.  Are you positive that's the lock on the
> > > backend filesystem and not the client-side lock (in case you're doing 
> a
> > > loopback mount?)
> > > 
> > > --b.
> > > 
> > > > 
> > > > 
> > > > 
> > > > 
> > > > From:   Bruce Fields <bfields@fieldses.org>
> > > > To:     Marc Eshel/Almaden/IBM@IBMUS
> > > > Cc:     linux-nfs@vger.kernel.org
> > > > Date:   07/01/2016 01:07 PM
> > > > Subject:        Re: grace period
> > > > 
> > > > 
> > > > 
> > > > On Fri, Jul 01, 2016 at 10:31:55AM -0700, Marc Eshel wrote:
> > > > > It used to be that sending KILL signal to lockd would free locks 
> and 
> > 
> > > > start 
> > > > > Grace period, and when setting nfsd threads to zero, 
> > > nfsd_last_thread() 
> > > > > calls nfsd_shutdown that called lockd_down that I believe was 
> > causing 
> > > > both 
> > > > > freeing of locks and starting grace period or maybe it was setting 
> 
> > it 
> > > > back 
> > > > > to a value > 0 that started the grace period.
> > > > 
> > > > OK, apologies, I didn't know (or forgot) that.
> > > > 
> > > > > Any way starting with the kernels that are in RHEL7.1 and up echo 
> 0 
> > > 
> > > > > /proc/fs/nfsd/threads doesn't do it anymore, I assume going to 
> > common 
> > > > > grace period for NLM and NFSv4 changed things.
> > > > > The question is how to do IP fail-over, so when a node fails and 
> the 
> > 
> > > IP 
> > > > is 
> > > > > moving to another node, we need to go into grace period on all the 
> 
> > > nodes 
> > > > 
> > > > > in the cluster so the locks of the failed node are not given to 
> > anyone 
> > > 
> > > > > other than the client that is reclaiming his locks. Restarting NFS 
> 
> > > > server 
> > > > > is to distractive.
> > > > 
> > > > What's the difference?  Just that clients don't have to reestablish 
> > tcp
> > > > connections?
> > > > 
> > > > --b.
> > > > 
> > > > > For NFSv3 KILL signal to lockd still works but for 
> > > > > NFSv4 have no way to do it for v4.
> > > > > Marc. 
> > > > > 
> > > > > 
> > > > > 
> > > > > From:   Bruce Fields <bfields@fieldses.org>
> > > > > To:     Marc Eshel/Almaden/IBM@IBMUS
> > > > > Cc:     linux-nfs@vger.kernel.org
> > > > > Date:   07/01/2016 09:09 AM
> > > > > Subject:        Re: grace period
> > > > > 
> > > > > 
> > > > > 
> > > > > On Thu, Jun 30, 2016 at 02:46:19PM -0700, Marc Eshel wrote:
> > > > > > I see that setting the number of nfsd threads to 0 (echo 0 > 
> > > > > > /proc/fs/nfsd/threads) is not releasing the locks and putting 
> the 
> > > > server 
> > > > > 
> > > > > > in grace mode.
> > > > > 
> > > > > Writing 0 to /proc/fs/nfsd/threads shuts down knfsd.  So it should
> > > > > certainly drop locks.  If that's not happening, there's a bug, but 
> 
> > > we'd
> > > > > need to know more details (version numbers, etc.) to help.
> > > > > 
> > > > > That alone has never been enough to start a grace period--you'd 
> have 
> > 
> > > to
> > > > > start knfsd again to do that.
> > > > > 
> > > > > > What is the best way to go into grace period, in new version of 
> > the
> > > > > > kernel, without restarting the nfs server?
> > > > > 
> > > > > Restarting the nfs server is the only way.  That's true on older 
> > > kernels
> > > > > true, as far as I know.  (OK, you can apparently make lockd do 
> > > something
> > > > > like this with a signal, I don't know if that's used much, and I 
> > doubt
> > > > > it works outside an NFSv3-only environment.)
> > > > > 
> > > > > So if you want locks dropped and a new grace period, then you 
> should 
> > 
> > > run
> > > > > "systemctl restart nfs-server", or your distro's equivalent.
> > > > > 
> > > > > But you're probably doing something more complicated than that. 
> I'm 
> > 
> > > not
> > > > > sure I understand the question....
> > > > > 
> > > > > --b.
> > > > > 
> > > > > 
> > > > > 
> > > > > 
> > > > 
> > > > 
> > > > 
> > > > 
> > > 
> > > 
> > > 
> > > 
> > 
> > 
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
> 
