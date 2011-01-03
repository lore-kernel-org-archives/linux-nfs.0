Return-Path: <nfsv4-bounces@ietf.org>
Message-ID: <4D21DB53.9050104@panasas.com>
Date: Mon, 03 Jan 2011 16:21:07 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Christoph Hellwig <hch@infradead.org>
References: <978693366.32.1292516428080.JavaMail.root@thunderbeast.private.linuxbox.com>
	<1740153586.34.1292516481789.JavaMail.root@thunderbeast.private.linuxbox.com>
	<20101216230707.GB16760@infradead.org>
In-Reply-To: <20101216230707.GB16760@infradead.org>
Cc: linux-nfs@vger.kernel.org, nfsv4@ietf.org
Subject: Re: [nfsv4] layoutcommits and file layout
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On 2010-12-17 01:07, Christoph Hellwig wrote:
> On Thu, Dec 16, 2010 at 11:21:21AM -0500, Matt W. Benjamin wrote:
>> Hi,
>>
>> We have a files implementation which wants to receive LAYOUTCOMMIT when a client is finished with a layout.  It was my clear understanding from rfc5661 that we could expect this behavior.
> 
> Care to post it to the list?
> 

I don't know what Matt's server is doing but the fundamental problem is
manifested with extending a file with parallel DS writes.
Assuming that the DS writes are executed in arbitrary order,
exposing the file length before LAYOUTCOMMIT can cause
a concurrent reader to read a hole.  Although locking can
solve this case, day-to-day applications that work well over
local filesystem and legacy NFS may break because of this.

Benny
_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
