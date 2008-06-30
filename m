From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 30 Jun 2008 11:30:03 -0400
Message-ID: <76bd70e30806300830p205bd918ve327a3e9e59a9fe3@mail.gmail.com>
References: <48652C24.6030409@gmail.com>
	 <OF20F6A497.A6F52D0F-ON65257478.00377AB6-65257478.0037E4AE@in.ibm.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Dean Hildebrand" <seattleplus@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Benny Halevy" <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	"Peter Staubach" <staubach@redhat.com>
To: "Krishna Kumar2" <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:59099 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761359AbYF3PaK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 11:30:10 -0400
Received: by yw-out-2324.google.com with SMTP id 9so775043ywe.1
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 08:30:04 -0700 (PDT)
In-Reply-To: <OF20F6A497.A6F52D0F-ON65257478.00377AB6-65257478.0037E4AE@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 6:10 AM, Krishna Kumar2 <krkumar2@in.ibm.com> wrote:
> Dean Hildebrand <seattleplus@gmail.com> wrote on 06/27/2008 11:36:28 PM:
>
>> One option might be to try using O_DIRECT if you are worried about
>> memory (although I would read/write in at least 1 MB at a time).  I
>> would expect this to help at least a bit especially on reads.
>>
>> Also, check all the standard nfs tuning stuff, #nfsds, #rpc slots.
>> Since with a loopback you effectively have no latency, you would want to
>> ensure that neither the #nfsds or #rpc slots is a bottleneck (if either
>> one is too low, you will have a problem).  One way to reduce the # of
>> requests and therefore require fewer nfsds/rpc_slots is to 'cat
>> /proc/mounts' to see your wsize/rsize.  Ensure your wsize/rsize is a
>> decent size (~ 1MB).
>
> Number of nfsd: 64, and
>      sunrpc.transports = sunrpc.udp_slot_table_entries = 128
>      sunrpc.tcp_slot_table_entries = 128

Interestingly, sometimes using a large number of slots can be
detrimental to performance over loopback.  Have you tried 32 and 64 as
well as 128?  Also, I seem to recall that you should have the same as
or fewer slots on your clients than you have threads on your server.

-- 
Chuck Lever
