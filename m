Return-Path: <bfields@fieldses.org>
Date: Tue, 19 Dec 2017 11:56:22 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: Re: spurious sillyrename after O_DIRECT writes get ENOSPC
Message-ID: <20171219165622.GC19967@fieldses.org>
References: <20171208221626.GB22508@fieldses.org>
 <20171213171815.GB9205@fieldses.org>
 <9383ABA6-B994-4DB3-95F4-C0D6F59580F9@redhat.com>
 <20171214163654.GD9205@fieldses.org>
 <20171214185514.GE9205@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171214185514.GE9205@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 14, 2017 at 01:55:14PM -0500, J. Bruce Fields wrote:
> So actually what happens is if you do a direct io write where some
> WRITEs succeed and the one fails, then this:
> 
> 	if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
> 		dreq->flags = 0;
> 		dreq->error = hdr->error;
> 	}
> 
> clears the NFS_ODIRECT_DO_COMMIT flag, so nfs_direct_write_complete
> never scheduels the commit calls.  It looks like that leaves a bunch of
> nfs_pages on some to-be-committed list, so we end up leaking a bunch of
> stuff, with the most visible symptom being an unnecessarily sillyrename
> on close.
> 
> I can just remove that clear of dreq_flags and that fixes the problem,
> but I doubt that's correct.

Or, maybe it is.  If *any* WRITE(s) involved in this write might need
a commit or reschedule, then surely we should run
nfs_direct_write_schedule_work and let it sort them out?  I'm having
trouble seeing why clearing that field partway through could ever be
correct.

Trond, Anna, does the following look right?

--b.
