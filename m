Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59366 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751979AbdFOUhn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Jun 2017 16:37:43 -0400
Date: Thu, 15 Jun 2017 16:37:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Mora, Jorge" <Jorge.Mora@netapp.com>
Cc: Olga Kornievskaia <aglo@umich.edu>,
        Anna Schumaker <schumakeranna@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] Inter server-side copy performance
Message-ID: <20170615203742.GA5319@fieldses.org>
References: <DFE33002-FE1C-4E83-B6E3-50BFD304C7F6@netapp.com>
 <20170413174515.GA5140@fieldses.org>
 <59BDF7CA-78BB-42FC-8BC4-95101F5E1EC7@netapp.com>
 <CAN-5tyHOdU9BJnJft+X06=6X7_s8MS_hDmg9t=fJQ=QtvJQD=w@mail.gmail.com>
 <20170417133604.GA22694@fieldses.org>
 <CAN-5tyF10OCihgYUMwoju6V+SnVZkpQNoQLb_UKoCAPuG+EgbQ@mail.gmail.com>
 <CAFX2JfkiraKm2Rmqhkrh3CSWBoYfW0QU=uXw=sSx-8Wt8JD7wg@mail.gmail.com>
 <CAN-5tyEO3wJ3sT_phM6LNGH3zpYmi21e+fhHjkSGvZrRqWziMw@mail.gmail.com>
 <20170418183333.GH6208@fieldses.org>
 <0E501639-4064-4EB8-8EFF-3F23CCA6A806@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <0E501639-4064-4EB8-8EFF-3F23CCA6A806@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks.

My main question is how close we get to what you'd expect given hardware
specs.  As long as it's in that neighborhood, then people will know what
to expect.

For example I'd expect server-to-server-copy bandwidth to be be roughly
the smallest of:

	- source server disk read bandwidth
	- destination server disk write bandwidth
	- network bandwidth

Which is actually the same I'd expect for a traditional copy, except
that the network bandwidth might be different.

But in your case, I'm guessing it's gigabit all around (and drive
bandwidth high enough not to matter).  And if my arithmetic is right,
traditional copy is getting around 700Mb/s and server-to-server copy
between 800 and 900 Mb/s depending on exactly how we do it?  Kinda
curious why traditional copy isn't doing better, I'd've thought we'd
have that pretty well optimized by now.

--b.

On Thu, Jun 15, 2017 at 07:29:24PM +0000, Mora, Jorge wrote:
> Here are the new numbers using latest SSC code for an 8GB copy.
> The code has a delayed unmount on the destination server which allows for single
> mount when multiple COPY calls are made back to back.
> Also, there is a third option which is using ioctl with a 64 bit copy length in order to 
> issue a single call for copy lengths >= 4GB.
> 
> Setup:
>      Client: 16 CPUs, 32GB
>      SRC server: 4 CPUs, 8GB
>      DST server: 4 CPUs, 8GB
> 
> Traditional copy:
>     DBG2: 20:31:43.683595 - Traditional COPY returns 8589934590 (96.8432810307 seconds)
> SSC (2 copy_file_range calls back to back):
>     DBG2: 20:30:00.268203 - Server-side COPY returns 8589934590 (83.0517759323 seconds)
>     PASS: SSC should outperform traditional copy, performance improvement for a 8GB file: 16%
> SSC (2 copy_file_range calls in parallel):
>     DBG2: 20:34:49.686573 - Server-side COPY returns 8589934590 (79.3080010414 seconds)
>     PASS: SSC should outperform traditional copy, performance improvement for a 8GB file: 20%
> SSC (1 ioctl call):
>     DBG2: 20:38:41.323774 - Server-side COPY returns 8589934590 (74.7774350643 seconds)
>     PASS: SSC should outperform traditional copy, performance improvement for a 8GB file: 28%
> 
> Since I don’t have three similar systems to test with, having the best machine (more cpu’s and more memory)
> as the client gives a better performance for the traditional copy. The following results are done using
> the best machine as the destination server instead.
> 
> Setup (using the best machine as the destination server instead):
>      Client: 4 CPUs, 8GB
>      SRC server: 4 CPUs, 8GB
>      DST server: 16 CPUs, 32GB
> 
> Traditional copy:
>     DBG2: 21:52:15.039625 - Traditional COPY returns 8589934590 (178.686635971 seconds)
> SSC (2 copy_file_range calls back to back):
>     DBG2: 21:49:08.961384 - Server-side COPY returns 8589934590 (173.071172953 seconds)
>     PASS: SSC should outperform traditional copy, performance improvement for a 8GB file: 3%
> SSC (2 copy_file_range calls in parallel):
>     DBG2: 21:35:59.822467 - Server-side COPY returns 8589934590 (159.743849993 seconds)
>     PASS: SSC should outperform traditional copy, performance improvement for a 8GB file: 18%
> SSC (1 ioctl call):
>     DBG2: 21:28:33.461528 - Server-side COPY returns 8589934590 (83.9983980656 seconds)
>     PASS: SSC should outperform traditional copy, performance improvement for a 8GB file: 119%
> 
> As you can see a single 8GB copy (ioctl with 64 bit copy length) performs the same as before (about 80 seconds)
> but in this case the traditional copy takes a lot longer.
> 
> 
> --Jorge
> 
> 
> On 4/18/17, 12:33 PM, "linux-nfs-owner@vger.kernel.org on behalf of J. Bruce Fields" <linux-nfs-owner@vger.kernel.org on behalf of bfields@fieldses.org> wrote:
> 
>     On Tue, Apr 18, 2017 at 01:28:39PM -0400, Olga Kornievskaia wrote:
>     > Given how the code is written now it looks like it's not possible to
>     > save up commits....
>     > 
>     > Here's what I can see happening:
>     > 
>     > nfs42_proc_clone() as well as nfs42_proc_copy() will call
>     > nfs_sync_inode(dst) "to make sure server(s) have the latest data"
>     > prior to initiating the clone/copy. So even if we just queue up (not
>     > send) the commit after the executing nfs42_proc_copy, then next call
>     > into vfs_copy_file_range() will send out that queued up commit.
>     > 
>     > Is it ok to relax the requirement that requirement, I'm not sure...
>     
>     Well, if the typical case of copy_file_range is just opening a file,
>     doing a single big copy_file_range(), then closing the file, then this
>     doesn't matter.
>     
>     The linux server is currently limiting COPY to 4MB at a time, which will
>     make the commits more annoying.
>     
>     Even there the typical case will probably still be an open, followed by
>     a series of non-overlapping copies, then close, and that shouldn't
>     require the commits.
>     
>     --b.
>     --
>     To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>     the body of a message to majordomo@vger.kernel.org
>     More majordomo info at  http://vger.kernel.org/majordomo-info.html
>     
> 
