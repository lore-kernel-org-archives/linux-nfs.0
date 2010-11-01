From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Regression, bisected: sqlite locking failure on nfs
Date: Mon, 1 Nov 2010 14:30:03 -0400
Message-ID: <187AEE96-9231-4899-9D65-A444503D2758@oracle.com>
References: <20101101175854.GA3550@elliptictech.com> <D68536EB-6BE9-4DE4-B325-39FEF747092E@oracle.com> <20101101181938.GA3875@elliptictech.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: LKML Kernel <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101101181938.GA3875@elliptictech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 1, 2010, at 2:19 PM, Nick Bowler wrote:

> On 2010-11-01 14:07 -0400, Chuck Lever wrote:
>> On Nov 1, 2010, at 1:58 PM, Nick Bowler wrote:
>>> After installing 2.6.37-rc1, attempting to use sqlite in any capacity on
>>> NFS gives a locking error:
>>> 
>>> % echo 'select * from blah;' | sqlite3 blah.sqlite
>>> Error: near line 1: database is locked
>>> 
>>> % echo 'create table blargh(INT);' | sqlite3 blargh.sqlite
>>> Error: near line 1: database is locked
>>> 
>>> The result is that a lot of high-profile applications which make use of
>>> sqlite fail mysteriously.  Bisection reveals the following, and
>>> reverting the implicated commit solves the issue:
>> 
>> Nick, thanks for the report.  Is 2.6.37-rc1 running on your clients or
>> on your server?
> 
> Sorry for not being clear: the client is running 2.6.37-rc1.   The
> server is running RHEL 5.5.
> 
>> Does anything interesting appear in the kernel log when your test case
>> fails?
> 
> There are no unusual messages on the client... but I just logged into
> the server and I see lots of messages of the following form:
> 
>  nfsd: request from insecure port (192.168.8.199:35766)!
>  nfsd: request from insecure port (192.168.8.199:35766)!
>  nfsd: request from insecure port (192.168.8.199:35766)!
>  nfsd: request from insecure port (192.168.8.199:35766)!
>  nfsd: request from insecure port (192.168.8.199:35766)!
> 
> (192.168.8.199 is the address of the failing client).  I can only assume
> that these are a result of my recent issues, since I don't have access
> to the system log (with timestamps) on that machine.

That's the problem this patch is supposed to prevent.  I'll investigate further.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
