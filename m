From: David Shaw <dshaw-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org>
Subject: Re: Kernel panic on 2.6.27.9 when NFS exporting
	fuse	filesystem
Date: Thu, 29 Jan 2009 09:00:56 -0500
Message-ID: <C63C470C-C086-4B70-ADD8-6BFDFA8DEF5F@jabberwocky.com>
References: <20090126225404.GA27937@jabberwocky.com>
	<E1LRtvN-0003zf-8b@pomaz-ex.szeredi.hu>
	<20090127220940.GE9151@fieldses.org>
	<20090127225608.GA13854@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>, Miklos Szeredi <miklos@szeredi.hu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <fuse-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090127225608.GA13854@fieldses.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=fuse-devel>
List-Post: <mailto:fuse-devel@lists.sourceforge.net>
List-Help: <mailto:fuse-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/fuse-devel>,
	<mailto:fuse-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: fuse-devel-bounces@lists.sourceforge.net
List-ID: <linux-nfs.vger.kernel.org>

On Jan 27, 2009, at 5:56 PM, J. Bruce Fields wrote:

> On Tue, Jan 27, 2009 at 05:09:40PM -0500, bfields wrote:
>> On Tue, Jan 27, 2009 at 08:48:41PM +0100, Miklos Szeredi wrote:
>>>
>>> The BUG triggers in this __module_get() in svc_recv():
>>>
>>> 			/*
>>> 			 * We know this module_get will succeed because the
>>> 			 * listener holds a reference too
>>> 			 */
>>> 			__module_get(newxpt->xpt_class->xcl_owner);
>>>
>>> Either the comment is wrong or something got corrupted.
>>>
>>> Tom, Bruce, any idea what could be causing this?  It doesn't really
>>> look fuse related.
>>
>> I seem to recall something being fixed recently there--I'll try to  
>> find
>> the commit id.
>
> Might have been 2da2c21d7508d34bc6d600df665d84871b65d2b9 "Add a
> reference to sunrpc in svc_addsock" ?

Very possibly.  That fix went into 2.6.28, and I can confirm that the  
problem does not reoccur under 2.6.28.2.

Thanks for your help!

David


------------------------------------------------------------------------------
This SF.net email is sponsored by:
SourcForge Community
SourceForge wants to tell your story.
http://p.sf.net/sfu/sf-spreadtheword
