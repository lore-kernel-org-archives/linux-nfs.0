Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:64404 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753327Ab3J2Nls convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 09:41:48 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Hellwig Christoph <hch@infradead.org>,
        "Haynes, Tom" <Tom.Haynes@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFS: Allow for asynchronous WRITE_PLUS calls
Date: Tue, 29 Oct 2013 13:41:47 +0000
Message-ID: <EC4979D8-9963-4BAF-BB30-15EA4FEBD5E3@netapp.com>
References: <1382972418-2249-1-git-send-email-bjschuma@netapp.com>
 <1382972418-2249-3-git-send-email-bjschuma@netapp.com>
 <20131029073943.GD10889@infradead.org>
 <BF996CAD-1032-4434-A538-B678D047884B@netapp.com>
 <20131029124836.GA13482@infradead.org>
 <58212CB2-A01A-43F1-8760-5ED8ED75E081@netapp.com>
 <20131029130857.GB32094@infradead.org>
 <78317EB5-0325-429B-89C8-F4092B677EC4@netapp.com>
 <20131029132421.GA13880@infradead.org>
In-Reply-To: <20131029132421.GA13880@infradead.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2013, at 9:24 AM, Hellwig Christoph <hch@infradead.org> wrote:

> On Tue, Oct 29, 2013 at 01:21:26PM +0000, Myklebust, Trond wrote:
>> The current draft spec even allows the client to specify a "pattern" to be written to the "hole".
> 
> That's indeed the WRITE SAME lookalike then.  At least the SCSI people
> were smart enough to define an unmap bit for "hole punching" and allow
> the target to reject all other versions if they don't want to support
> it.
> 
> Given that NFS v4.2 isn't finalized I'd very much recommend to
> 
> a) properly separate those case s
> b) do not make the async version mandatory

   union write_plus_arg4 switch (data_content4 wpa_content) {
   case NFS4_CONTENT_DATA:
           data4           wpa_data;
   case NFS4_CONTENT_APP_DATA_HOLE:
           app_data_hole4  wpa_adh;
   case NFS4_CONTENT_HOLE:
           data_info4      wpa_hole;
   default:
           void;
   };

I suppose we could add cases: NFS4_CONTENT_APP_DATA_HOLE_SYNC, NFS4_CONTENT_HOLE_SYNC to allow the client to specify that it doesn't want asynchronous behaviour (and add error cases to allow the server to specify that it cannot safely do so).

There is already a 'di_allocated' boolean for the NFS4_CONTENT_HOLE case (which is used to distinguish between holes and zeroed extents). The only thing missing there is an error case, AFAICS, to allow the server to return that it doesn't support holes.

Tom, any thoughts on whether or not this kind of change to the spec is doable at this time?

