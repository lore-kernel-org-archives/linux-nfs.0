Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:37140 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758027Ab2C2Bln (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 21:41:43 -0400
Date: Wed, 28 Mar 2012 21:41:39 -0400
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Namjae Jeon <linkinjeon@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4: Fix two infinite loops in the mount code
Message-ID: <20120329014139.GA29997@umich.edu>
References: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
 <38AF6CFC-8017-4D08-8DB0-A80BA724E54A@netapp.com>
 <1332947296.11400.7.camel@lade.trondhjem.org>
 <74BCDDD5-955E-4C06-9640-47D477A9FF8F@netapp.com>
 <CAKYAXd-eWRrja8bGqS7tTWehPNgAM4gtPALfAexRvTwkbbBOGw@mail.gmail.com>
 <1332979882.19172.38.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332979882.19172.38.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  On Thu, 2012-03-29 at 08:55 +0900, Namjae Jeon wrote:
  > Hi. Trond.
  > 
  > Normally goto statement is not recommended(pipeline and branch
  > prediction) it is only recommended as a last resort if there is no
  > method to escape this loop.
  
  ????????????? A goto is an unconditional branch; there is no further
  branch prediction involved once once the processor gets the value of
  'err' in that switch statement correct. Exactly how would adding an
  extra set+test of exception.retry after the switch() help the branch
  predictor in this situation?

Besides which I see little point in optimizing this error path.
