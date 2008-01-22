From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs: parenthesize NFS_*(inode) parameters
Date: Tue, 22 Jan 2008 18:53:18 +0200
Message-ID: <47961F7E.8060207@panasas.com>
References: <200801221606.LAA15590@snowhite.cis.uoguelph.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, NFSv4@linux-nfs.org
To: Rick Macklem <rick@snowhite.cis.uoguelph.ca>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <200801221606.LAA15590@snowhite.cis.uoguelph.ca>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan. 22, 2008, 18:06 +0200, Rick Macklem <rick@snowhite.cis.uoguelph.ca> wrote:
>>> They should really be converted into inlined functions.
>>>
>>> Cheers
>>>   Trond
>> Agreed.  How about the following:
> 
> Ok, you've tickled my curiosity...why? Unless a macro is large and is
> used many times (my really old nfs code was like that, being written
> for a compiler that didn't support inline functions), what is the
> advantage of inline functions? Or is it just that the code is more readable?

Let me quote Jeff Garzik in http://lwn.net/2000/1123/a/Linus-HOWTO.php3:

	3) 'static inline' is better than a macro

	Static inline functions are greatly preferred over macros.
	They provide type safety, have no length limitations, no formatting
	limitations, and under gcc they are as cheap as macros.

	Macros should only be used for cases where a static inline is clearly
	suboptimal [there a few, isolated cases of this in fast paths],
	or where it is impossible to use a static inline function [such as
	string-izing].

So for zero cost in performance you get safer, scope isolated, and more readable
code.

Benny

> 
> Just curious, I don't have any problem with using inline functions, rick
