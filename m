From: "Gilliam, PaulX J" <paulx.j.gilliam@intel.com>
Subject: RE: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
Date: Tue, 15 Jun 2010 11:01:11 -0700
Message-ID: <0A97A441BFADC74EA1E299A79C69DF9213D49EB758@orsmsx504.amr.corp.intel.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
	 <0A97A441BFADC74EA1E299A79C69DF9213D49EB687@orsmsx504.amr.corp.intel.com>
 <1276623141.8767.47.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:50142 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217Ab0FOSBO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 14:01:14 -0400
In-Reply-To: <1276623141.8767.47.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>-----Original Message-----
>From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
>Sent: Tuesday, June 15, 2010 10:32 AM
>To: Gilliam, PaulX J
>Cc: linux-nfs@vger.kernel.org
>Subject: RE: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
>
>On Tue, 2010-06-15 at 09:50 -0700, Gilliam, PaulX J wrote:
>> > -----Original Message-----
>> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>owner@vger.kernel.org] On Behalf Of Trond Myklebust
>> > Sent: Monday, June 14, 2010 2:51 PM
>> > To: linux-nfs@vger.kernel.org
>> > Subject: [PATCH 02/15] NFSv4.1: Clean up nfs4_setup_sequence
>> >
>> > Firstly, there is little point in first zeroing out the entire struct
>> > nfs4_sequence_res, and then initialising all fields save one. Just
>> > initialise the last field to zero...
>>
>> The reason one may want to zero out the entire struct is that in the
>future, someone may add elements to the struct.  In that case,
>> 	memset(res, 0, sizeof(*res));
>> would not have to be changed, and any new elements will "automatically"
>be initialized to a known value.
>>
>> Just a thought.
>
>That assumes this is a structure that is likely to change and/or be
>extended in the future, which is unlikely since the NFSv4.1 protocol
>specification is complete and the SEQUENCE results are fully contained
>in the current set of fields.

Good point.


>
>It also assumes that '0' would be a desirable default value for these
>new fields.
>
>Trond

I think '0' would be a desirable default only in that it could lead to detecting errors earlier.


Back in olden times, Windows NT came in two flavors: "checked" and "unchecked".  The "checked" version was much slower and took more resources, but had a ton of "extra" code to check for bad things.  It was expected that the "unchecked" version would actually be the one for daily use.

If Linux had a similar thing (maybe it does?) one could use something like this:

#ifdef(CHECKED)
	memset(res, 0, sizeof(*res));
#endif


Maybe not in this specific case, but in general.

I'll shut up now and go back to lurking.

-=# Paul Gilliam #=-  
