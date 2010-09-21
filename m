Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34079 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456Ab0IUNxZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 09:53:25 -0400
Date: Tue, 21 Sep 2010 09:51:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: George Mamalakis <mamalos@eng.auth.gr>
Cc: linux-nfs@vger.kernel.org, kwc@citi.umich.edu
Subject: Re: nfsv3 gssapi client?
Message-ID: <20100921135157.GA26473@fieldses.org>
References: <4C938F3B.4030604@eng.auth.gr>
 <20100917174328.GC25515@fieldses.org>
 <4C972DB3.2050405@eng.auth.gr>
 <20100920145643.GD4580@fieldses.org>
 <4C978008.50805@eng.auth.gr>
 <20100920160732.GK4580@fieldses.org>
 <4C986E82.7040003@eng.auth.gr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C986E82.7040003@eng.auth.gr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Sep 21, 2010 at 11:36:18AM +0300, George Mamalakis wrote:
>  Hi guys,
> 
> Kevin:
> As stated in my first email, the linux box is running on a 2.6.35
> kernel, heimdal 1.3.3-1 (the version was not mentioned in my email),

As Kevin says, it would be worth trying MIT kerberos instead of heimdal
if you can, as that is generally better tested.

--b.

> rpcbind-0.2.0-2, nfs-utils-1.2.2-3, and the distro is arch-linux.
> 
> Bruce: I would rather find an "easier" (configuration-specific) way
> to overcome my problem instead of delving into the code, since I am
> not a developer (I am an admin :)). Nevertheless, when I used
> google.com/searchcode for _gss_get_mechanism_cred I found that there
> is a libgss/g_glue.c that defines this function in the following way
> (the site is svn://svn.genunix.org/on/trunk <http://google.com/codesearch/p?hl=en#m0BoFGhUuEY/&q=_gss_get_mechanism_cred>):
> 
> /*
>  * Glue routine for returning the mechanism-specific credential from a
>  * external union credential.
>  */
> gss_cred_id_t
> __gss_get_mechanism_cred(union_cred, mech_type)
>         const  gss_union_cred_t  union_cred;
>         const  gss_OID           mech_type;
> {
>         int                      i;
> 
>         if  (union_cred == (gss_union_cred_t)GSS_C_NO_CREDENTIAL)
>                 return  (GSS_C_NO_CREDENTIAL);
> 
>         for  (i =0; i<  union_cred->count; i++) {
>                 if  (g_OID_equal(mech_type,&union_cred->mechs_array[i]))
>                         return  (union_cred->cred_array[i]);
>         }
>         return  (GSS_C_NO_CREDENTIAL);
> }
> 
> 
> where you can see that the guy returns a cred_array[i] element, that
> obviously is null, because (most probably) the if statement above
> did not match any "compatible" mechanisms during the recursion.
> 
> Maybe I am totally wrong, since I haven't checked the code
> thoroughly, but I think that the problem is located somewhere in
> this code segment.
> 
> As I stated before, I was rather hoping to avoid this procedure,
> since I decided to use the linux distro for my clients due to its
> 'out-of-the-box' and 'everything-is-supported' benefits as
> (slightly-)opposed to fbsd (which I use in all my servers and
> personal computers, and "love" as an operating system) can be a bit
> more "demanding" when out-of-the-box-general-purpose issues are
> involved. The thing is that the client will be used as a
> general-purpose student pc in a university lab.
> 
> Thanx again for your help,
> 
> if anybody could direct me somewhere else I would be delighted to know so!
> 
> mamalos
> 
> -- 
> George Mamalakis
> 
> IT Officer
> Electrical and Computer Engineer (Aristotle Un. of Thessaloniki),
> MSc (Imperial College of London)
> 
> Department of Electrical and Computer Engineering
> Faculty of Engineering
> Aristotle University of Thessaloniki
> 
> phone number : +30 (2310) 994379
> 
