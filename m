Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22516 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764Ab1IZMxG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 08:53:06 -0400
Message-ID: <4E807588.8040904@netapp.com>
Date: Mon, 26 Sep 2011 08:52:24 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Sukwoo Kang <sukwoo.kang@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 read delegation
References: <CAOB=RsJUwPsU4gjnW208wYJ-VCsbRovyg3xEfHn2boWwGicZ=w@mail.gmail.com>
In-Reply-To: <CAOB=RsJUwPsU4gjnW208wYJ-VCsbRovyg3xEfHn2boWwGicZ=w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 09/23/2011 08:17 PM, Sukwoo Kang wrote:
> Hello, I'm trying to find out how NFSv4 client can get read
> delegation. I'm using separate RHEL6 machines (2.6.32-71.el6.x86_64)
> as server and client respectively.

I'm able to get a read delegation by holding two files open at the same time.

$ tail -f /nfs/file1.txt
$ tail -f /nfs/file2.txt

Will give me a read delegation in the second OPEN reply.

- Bryan

> 
> If I use pynfs, I can see server gives out read delegation. Basically
> pynfs sends these RPCs to server - open (create), open_confirm, open,
> open_confirm.
> 
> On real NFS client,
> 
> If I do 'cat <file>' twice, client does not get read delegation.
> 	- (nfs4state.c)
> 	- if (!cb_up || !sop->so_confirmed)
> 		goto out;
> 	- Here sop->so_confirmed is 0.
> 
> If I open the existing file with O_RDONLY twice (i.e., open, not close
> it and open again), client sends open only once to server.
> 	- So here also sop->so_confirmed is 0. Delegation is not sent out.
> (I've added more debug messages shown in below.)
> 
> 2011-09-23T22:41:44.642938+02:00 int002st001 kernel: NFSD:
> nfs4_open_delegation enter
> 2011-09-23T22:41:44.642942+02:00 int002st001 kernel: NFSD: nfs4_open_claim_null
> 2011-09-23T22:41:44.643853+02:00 int002st001 kernel: NFSD: cb_up=1,
> sop->so_confirmed=0
> 2011-09-23T22:41:44.643857+02:00 int002st001 kernel: NFSD: either
> callback is not up or not open confirmed
> 2011-09-23T22:41:44.643858+02:00 int002st001 kernel: NFSD:
> nfs4_open_delegation exit
> 
> If I open the existing file with O_RDWR and then open it with
> O_RDONLY, I can see "sop->so_confirmed = 1", but setlease failed.
> 	- I think it is because there is writer on this file.
> 
> 2011-09-23T11:23:28.116280+02:00 int002st001 kernel: NFSD:
> nfs4_open_delegation enter
> 2011-09-23T11:23:28.116717+02:00 int002st001 kernel: NFSD: nfs4_open_claim_null
> 2011-09-23T11:23:28.117879+02:00 int002st001 kernel: NFSD: cb_up=1,
> sop->so_confirmed=1
> 2011-09-23T11:23:28.117887+02:00 int002st001 kernel: NFSD alloc_init_deleg
> 2011-09-23T11:23:28.117889+02:00 int002st001 kernel: NFSD: setlease
> failed [-11], no delegation
> 2011-09-23T11:23:28.119101+02:00 int002st001 kernel: NFSD:
> close_delegation dp ffff88006ba05e60
> 2011-09-23T11:23:28.119109+02:00 int002st001 kernel: NFSD: freeing dp
> ffff88006ba05e60
> 2011-09-23T11:23:28.120050+02:00 int002st001 kernel: NFSD:
> nfs4_open_delegation exit
> 
> What is missing here? I will appreciate any advice. Thank you.
> 	
> Regards,
> Sukwoo Kang
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

