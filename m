Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:54622 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888Ab1DFTgX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Apr 2011 15:36:23 -0400
Date: Wed, 6 Apr 2011 15:36:19 -0400
From: Jim Rees <rees@umich.edu>
To: Tom Haynes <tdh@excfb.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Olga Kornievskaia <aglo@citi.umich.edu>, Joe Perches <joe@perches.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: rc4-hmac-md5 mount failure
Message-ID: <20110406193619.GB9033@merit.edu>
References: <AANLkTikRJad_vR1qxL1Wr4AO0OfP32oCYj4X0cTnVwv+@mail.gmail.com>
 <1302110267.7020.8.camel@lade.trondhjem.org>
 <20110406173631.GA8741@merit.edu>
 <4D9CB9E4.1090902@excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D9CB9E4.1090902@excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Tom Haynes wrote:

  Because it is no longer on the stack?

Yes, that much is obvious.  What I didn't understand was the part about
virt_to_page().
