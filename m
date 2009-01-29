From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [fuse-devel] Kernel panic on 2.6.27.9 when NFS exporting fuse
	filesystem
Date: Thu, 29 Jan 2009 10:34:01 -0500
Message-ID: <20090129153401.GB24712@fieldses.org>
References: <20090126225404.GA27937@jabberwocky.com> <E1LRtvN-0003zf-8b@pomaz-ex.szeredi.hu> <20090127220940.GE9151@fieldses.org> <20090127225608.GA13854@fieldses.org> <C63C470C-C086-4B70-ADD8-6BFDFA8DEF5F@jabberwocky.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miklos Szeredi <miklos@szeredi.hu>,
	fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: David Shaw <dshaw-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51968 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbZA2PeF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jan 2009 10:34:05 -0500
In-Reply-To: <C63C470C-C086-4B70-ADD8-6BFDFA8DEF5F-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 29, 2009 at 09:00:56AM -0500, David Shaw wrote:
> On Jan 27, 2009, at 5:56 PM, J. Bruce Fields wrote:
>
>> On Tue, Jan 27, 2009 at 05:09:40PM -0500, bfields wrote:
>>> On Tue, Jan 27, 2009 at 08:48:41PM +0100, Miklos Szeredi wrote:
>>>>
>>>> The BUG triggers in this __module_get() in svc_recv():
>>>>
>>>> 			/*
>>>> 			 * We know this module_get will succeed because the
>>>> 			 * listener holds a reference too
>>>> 			 */
>>>> 			__module_get(newxpt->xpt_class->xcl_owner);
>>>>
>>>> Either the comment is wrong or something got corrupted.
>>>>
>>>> Tom, Bruce, any idea what could be causing this?  It doesn't really
>>>> look fuse related.
>>>
>>> I seem to recall something being fixed recently there--I'll try to  
>>> find
>>> the commit id.
>>
>> Might have been 2da2c21d7508d34bc6d600df665d84871b65d2b9 "Add a
>> reference to sunrpc in svc_addsock" ?
>
> Very possibly.  That fix went into 2.6.28, and I can confirm that the  
> problem does not reoccur under 2.6.28.2.
>
> Thanks for your help!

Thanks for the confirmation.--b.
