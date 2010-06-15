From: "Gilliam, PaulX J" <paulx.j.gilliam@intel.com>
Subject: RE: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
Date: Tue, 15 Jun 2010 09:50:40 -0700
Message-ID: <0A97A441BFADC74EA1E299A79C69DF9213D49EB687@orsmsx504.amr.corp.intel.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53584 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757504Ab0FOQuq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 12:50:46 -0400
In-Reply-To: <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
> Sent: Monday, June 14, 2010 2:51 PM
> To: linux-nfs@vger.kernel.org
> Subject: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
> 
> Firstly, there is little point in first zeroing out the entire struct
> nfs4_sequence_res, and then initialising all fields save one. Just
> initialise the last field to zero...

The reason one may want to zero out the entire struct is that in the future, someone may add elements to the struct.  In that case, 
	memset(res, 0, sizeof(*res));
would not have to be changed, and any new elements will "automatically" be initialized to a known value.

Just a thought.

-=# Paul Gilliam #=-
