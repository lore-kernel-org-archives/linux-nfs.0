Return-Path: <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH][RESEND] pnfs/blocklayout: fix last_write_offset
 incorrectly set to page boundary
To: Christoph Hellwig <hch@infradead.org>
References: <ffe9a2cc97ead5b73b985aa4c16219351cac29d5.1476215430.git.bcodding@redhat.com>
 <20161011201719.GA25383@infradead.org>
 <bf99210e-7aea-74ee-799c-64c7f190b4e4@Netapp.com>
 <20161021121847.GA13905@infradead.org>
CC: Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust
	<trond.myklebust@primarydata.com>,
        <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <3d86cc79-81f5-0b7b-1218-d9d26807859b@Netapp.com>
Date: Fri, 21 Oct 2016 10:58:02 -0400
MIME-Version: 1.0
In-Reply-To: <20161021121847.GA13905@infradead.org>
Content-Type: text/plain; charset="utf-8"
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

On 10/21/2016 08:18 AM, Christoph Hellwig wrote:
> On Thu, Oct 13, 2016 at 04:46:19PM -0400, Anna Schumaker wrote:
>> Hi Ben,
>>
>> Thanks for the patch!  It didn't make it into my initial pull request for 4.9, but I am planning on sending it for an rc along with any bakeathon changes from next week.
> 
> Any progress on that?  I'd really like to get the fix in before at least
> -rc2.
> 

I have the patch is my tree ready to go!  I've been holding back since the NFS Bakeathon is this week, and I was waiting to see if any bugfixes were posted that I could send off at the same time.

Anna
