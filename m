Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60332 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757987Ab1FIN6s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 09:58:48 -0400
Date: Thu, 9 Jun 2011 09:58:46 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
Message-ID: <20110609135846.GA32565@merit.edu>
References: <cover.1307464381.git.rees@umich.edu>
 <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
 <4DEED80A.4000102@panasas.com>
 <20110608021852.GA20998@merit.edu>
 <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com>
 <4DF062D6.7010304@panasas.com>
 <20110609114929.GA28157@merit.edu>
 <4DF0CB5D.60000@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DF0CB5D.60000@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  > My understanding is that layoutget specifies a min and max, and the server
  
  There's a min.  What do you consider the max?
  Whatever gets into csa_fore_chan_attrs.ca_maxresponsesize?

The spec doesn't say max, it says "desired."  I guess I assumed the server
wouldn't normally return more than desired.

18.43.3.  DESCRIPTION
...

   The LAYOUTGET operation returns layout information for the specified
   byte-range: a layout.  The client actually specifies two ranges, both
   starting at the offset in the loga_offset field.  The first range is
   between loga_offset and loga_offset + loga_length - 1 inclusive.
   This range indicates the desired range the client wants the layout to
   cover.  The second range is between loga_offset and loga_offset +
   loga_minlength - 1 inclusive.  This range indicates the required
   range the client needs the layout to cover.  Thus, loga_minlength
   MUST be less than or equal to loga_length.
