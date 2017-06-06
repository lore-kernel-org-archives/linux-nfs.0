Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: GSS sequence number window
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <C7BDFB27-72B4-4156-8272-BAE8AE89039B@oracle.com>
Date: Tue, 6 Jun 2017 15:35:23 -0400
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <28665890-C74A-4319-B42E-475393821EC7@oracle.com>
References: <63736845-2BD3-4EE1-AC12-0BD21A9ABEF2@oracle.com> <20170530193419.GA9371@fieldses.org> <EC0579A3-BC81-4398-A11D-8D8EEFC473BF@redhat.com> <20170531192231.GA23526@fieldses.org> <C7BDFB27-72B4-4156-8272-BAE8AE89039B@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>


> On May 31, 2017, at 4:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On May 31, 2017, at 3:22 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> 
>> On Tue, May 30, 2017 at 04:11:20PM -0400, Benjamin Coddington wrote:
>>> On 30 May 2017, at 15:34, J. Bruce Fields wrote:
>>> 
>>>> On Tue, May 30, 2017 at 02:58:00PM -0400, Chuck Lever wrote:
>>>>> Hey Bruce!
>>>>> 
>>>>> While testing with sec=krb5 and sec=krb5i, I noticed a lot of
>>>>> spurious connection loss, especially when I wanted to run a
>>>>> CPU-intensive workload on my NFS server at the same time I
>>>>> was testing.
>>>>> 
>>>>> I added a pr_err() in gss_check_seq_num, and ran a fio job
>>>>> on a vers=3,sec=sys,proto=tcp mount (server is exporting a
>>>>> tmpfs). On the server, I rebuilt a kernel source tree cscope
>>>>> database at the same time.
>>>>> 
>>>>> May 29 17:53:13 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 250098, sd_max = 250291, GSS_SEQ_WIN = 128
>>>>> May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 937816, sd_max = 938171, GSS_SEQ_WIN = 128
>>>>> May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 938544, sd_max = 938727, GSS_SEQ_WIN = 128
>>>>> May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 938543, sd_max = 938727, GSS_SEQ_WIN = 128
>>>>> May 29 17:53:34 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 939344, sd_max = 939549, GSS_SEQ_WIN = 128
>>>>> May 29 17:53:35 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 965007, sd_max = 965176, GSS_SEQ_WIN = 128
>>>>> May 29 17:54:01 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 1799710, sd_max = 1799982, GSS_SEQ_WIN = 128
>>>>> May 29 17:54:02 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 1831165, sd_max = 1831353, GSS_SEQ_WIN = 128
>>>>> May 29 17:54:04 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 1883583, sd_max = 1883761, GSS_SEQ_WIN = 128
>>>>> May 29 17:54:07 klimt kernel: gss_check_seq_num: seq_num =
>>>>> 1959316, sd_max = 1959447, GSS_SEQ_WIN = 128
>>>>> 
>>>>> RFC 2203 suggests there's no risk to using a large window.
>>>>> My first thought was to make the sequence window larger
>>>>> (say 2048) but I've seen stragglers outside even that large
>>>>> a window.
>>>>> 
>>>>> Any thoughts about why there are these sequence number
>>>>> outliers?
>>>> 
>>>> No, alas.
>>> 
>>> I noticed some slow allocations on the server with krb5 last year - but
>>> never got around to doing anything about it:
>>> http://marc.info/?t=146032122900006&r=1&w=2
>>> 
>>> Could be the same thing?
>> 
>> I don't think it would be too hard to eliminate the need for allocations
>> there.  Or maybe there's even a quick hack that would let Chuck test
>> whether that's the problem (different GFP flags on those allocations?)
> 
> This doesn't feel like a memory allocator issue. My server has
> loads of free memory, and there's just one NUMA node.
> 
> Since increasing nfsd thread count seems to improve the situation,
> my guess is that having more threads available makes it less likely
> that an RPC request will be reordered.

I filed https://bugzilla.linux-nfs.org/show_bug.cgi?id=306

To check memory allocation latency, I could always construct
a framework around kmalloc and alloc_page.


I've also found some bad behavior around proto=rdma,sec=krb5i.
When I run a heavy I/O workload (fio, for example), every so
often a read operation fails with EIO. I dug into it a little
and MIC verification fails for these replies on the client.

I filed https://bugzilla.linux-nfs.org/show_bug.cgi?id=307
to document this second issue.

I'm not sure what a next step would be. My suspicion is that
either the server or the client is mishandling the RPC reply
buffer, which causes the checksums to be different. Not sure
why this would be so intermittent, though.


--
Chuck Lever
