Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: GSS sequence number window
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170606194158.GG13376@fieldses.org>
Date: Tue, 6 Jun 2017 15:45:59 -0400
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4D542D55-DCBA-4838-9DB2-B76B4068783E@oracle.com>
References: <63736845-2BD3-4EE1-AC12-0BD21A9ABEF2@oracle.com> <20170530193419.GA9371@fieldses.org> <EC0579A3-BC81-4398-A11D-8D8EEFC473BF@redhat.com> <20170531192231.GA23526@fieldses.org> <C7BDFB27-72B4-4156-8272-BAE8AE89039B@oracle.com> <28665890-C74A-4319-B42E-475393821EC7@oracle.com> <20170606194158.GG13376@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 6, 2017, at 3:41 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Tue, Jun 06, 2017 at 03:35:23PM -0400, Chuck Lever wrote:
>> I filed https://bugzilla.linux-nfs.org/show_bug.cgi?id=306
>> 
>> To check memory allocation latency, I could always construct
>> a framework around kmalloc and alloc_page.
>> 
>> 
>> I've also found some bad behavior around proto=rdma,sec=krb5i.
>> When I run a heavy I/O workload (fio, for example), every so
>> often a read operation fails with EIO. I dug into it a little
>> and MIC verification fails for these replies on the client.
> 
> Do we still have the problem that the read data can change between the
> time we calculate the MIC and the time we transmit the data to the
> client?

I don't see a problem with krb5p, which, if IIUC, would also
fall victim to this situation, unless there is much stricter
request serialization going on with krb5p.

Even so, how would I detect if this issue was present?


> --b.
> 
>> 
>> I filed https://bugzilla.linux-nfs.org/show_bug.cgi?id=307
>> to document this second issue.
>> 
>> I'm not sure what a next step would be. My suspicion is that
>> either the server or the client is mishandling the RPC reply
>> buffer, which causes the checksums to be different. Not sure
>> why this would be so intermittent, though.

--
Chuck Lever
