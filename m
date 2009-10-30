From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/8] param: use ops in struct kernel_param, rather than get and set fns directly
Date: Fri, 30 Oct 2009 21:43:39 +1030
Message-ID: <200910302143.40268.rusty@rustcorp.com.au>
References: <20091022142337.EC4A85362F@mx1.suse.de> <s5hvdhxyyl7.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ville Syrjala <syrjala-ORSVBvAovxo@public.gmane.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Alessandro Rubini <rubini-JCs+bAQazDroPXhRcRtihA@public.gmane.org>,
	Michal Januszewski <spock@gentoo.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, linux-input@vger.kernel.org,
	linux-fbdev-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
To: Takashi Iwai <tiwai@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47756 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754643AbZJ3LNh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Oct 2009 07:13:37 -0400
In-Reply-To: <s5hvdhxyyl7.wl%tiwai@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 30 Oct 2009 08:48:12 pm Takashi Iwai wrote:
> At Fri, 23 Oct 2009 00:51:28 +1030,
> Rusty Russell wrote:
> > 
> > This is more kernel-ish, saves some space, and also allows us to
> > expand the ops without breaking all the callers who are happy for the
> > new members to be NULL.
> > 
> > The few places which defined their own param types are changed to the
> > new scheme.
> > 
> > Since we're touching them anyway, we change get and set to take a
> > const struct kernel_param (which they were, and will be again).
> > 
> > To reduce churn, module_param_call creates the ops struct so the callers
> > don't have to change (and casts the functions to reduce warnings).
> > The modern version which takes an ops struct is called module_param_cb.
> 
> This is nice, as it also reduces the size of struct kernel_param, so
> each parameter uses less footprint (who cares, though?) :)
> 
> But, just wondering whether we still need to export get/set
> functions.  They can be called from ops now, so if any, it can be
> defined even as an inlinefunction or a macro.

My thought too, so I tried that, but many are still used like so:

	module_param_call(foo, set_foo, param_get_uint, NULL, 0644);

They can all be replaced in time with something like:
	static int param_get_foo(char *buffer, const struct kernel_param *kp)
	{
		return param_ops_uint.get(buffer, kp);
	}

But it'll take a transition period.

Thanks!
Rusty.



> 
> 
> thanks,
> 
> Takashi
> 
