From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 30 Jun 2008 11:35:43 -0400
Message-ID: <76bd70e30806300835u6192fa91l2cfff53f2ea85e11@mail.gmail.com>
References: <48652C24.6030409@gmail.com>
	 <OF20F6A497.A6F52D0F-ON65257478.00377AB6-65257478.0037E4AE@in.ibm.com>
	 <20080630112654.012ce3e4@barsoom.rdu.redhat.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Krishna Kumar2" <krkumar2@in.ibm.com>,
	"Dean Hildebrand" <seattleplus@gmail.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Benny Halevy" <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	"Peter Staubach" <staubach@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:8734 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762929AbYF3Pfr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 11:35:47 -0400
Received: by yw-out-2324.google.com with SMTP id 9so776021ywe.1
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 08:35:44 -0700 (PDT)
In-Reply-To: <20080630112654.012ce3e4-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 11:26 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Mon, 30 Jun 2008 15:40:30 +0530
> Krishna Kumar2 <krkumar2@in.ibm.com> wrote:
>
>> Dean Hildebrand <seattleplus@gmail.com> wrote on 06/27/2008 11:36:28 PM:
>>
>> > One option might be to try using O_DIRECT if you are worried about
>> > memory (although I would read/write in at least 1 MB at a time).  I
>> > would expect this to help at least a bit especially on reads.
>> >
>> > Also, check all the standard nfs tuning stuff, #nfsds, #rpc slots.
>> > Since with a loopback you effectively have no latency, you would want to
>> > ensure that neither the #nfsds or #rpc slots is a bottleneck (if either
>> > one is too low, you will have a problem).  One way to reduce the # of
>> > requests and therefore require fewer nfsds/rpc_slots is to 'cat
>> > /proc/mounts' to see your wsize/rsize.  Ensure your wsize/rsize is a
>> > decent size (~ 1MB).
>>
>> Number of nfsd: 64, and
>>       sunrpc.transports = sunrpc.udp_slot_table_entries = 128
>>       sunrpc.tcp_slot_table_entries = 128
>>
>> I am using:
>>
>>       mount -o
>> rw,bg,hard,nointr,proto=tcp,vers=3,rsize=65536,wsize=65536,timeo=600,noatime
>>  localhost:/local /nfs
>>
>> I have also tried with 1MB for both rsize/wsize and it didn't change the BW
>> (other than
>> mini variations).
>>
>> thanks,
>>
>> - KK
>>
>
> Recently I spent some time with others here at Red Hat looking
> at problems with nfs server performance. One thing we found was that
> there are some problems with multiple nfsd's. It seems like the I/O
> scheduling or something is fooled by the fact that sequential write
> calls are often handled by different nfsd's. This can negatively
> impact performance (I don't think we've tracked this down completely
> yet, however).

Yeah, I think that's what Dean is alluding to above.  There was a
FreeNix paper a few years back that discusses this same readahead
problem with the FreeBSD NFS server.

-- 
Chuck Lever
