Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp110.prem.mail.ac4.yahoo.com ([76.13.13.93]:38727 "HELO
	smtp110.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757414Ab0HaOge (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Aug 2010 10:36:34 -0400
Date: Tue, 31 Aug 2010 09:36:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
To: Kian Mohageri <kian.mohageri@gmail.com>
cc: davidr@ressman.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: fsync/wb deadlocks in 2.6.32
In-Reply-To: <AANLkTinieSM_-x4qra7_HOCsONFAdyjn3LQbyBDJRebT@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1008310934150.867@router.home>
References: <AANLkTikWR_YSnx=4=KAodATpX+xO9+hj-cf7_e158f4d@mail.gmail.com> <AANLkTi=gj901aF_84+40j9MhvAwNJSNB8qRnpY8o0gBZ@mail.gmail.com> <AANLkTinEoMgXLvN4MvfnCHjHtHCwV1HDP67BoKQ3ZbQx@mail.gmail.com> <alpine.DEB.2.00.1008301101560.10316@router.home>
 <AANLkTinieSM_-x4qra7_HOCsONFAdyjn3LQbyBDJRebT@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We got another instance yesterday. A large number of machines
simultaneously started spewing the kernel messages. Had to reboot to get
the state cleared up. Very very annoying. Anyone know a reason for these
writeback deadlocks?

