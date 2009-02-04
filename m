From: Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: Re: [PATCH] Bug 11061, NFS mounts dropped
Date: Thu, 05 Feb 2009 08:11:47 +1030
Message-ID: <1233783707.13862.121.camel@sibyl.beware.dropbear.id.au>
References: <1233459927.3112.54.camel@sibyl.beware.dropbear.id.au>
	 <BD6791E5-9D82-4D42-8016-4731792CA5DA@oracle.com>
	 <1233610918.3077.50.camel@sibyl.beware.dropbear.id.au>
	 <157D0C13-65A3-412D-A266-EDFCF487F632@oracle.com>
	 <1233698189.13862.16.camel@sibyl.beware.dropbear.id.au>
	 <2A59F69E-7E14-4E20-9F9E-EF9B02326342@oracle.com>
	 <1233751955.13862.68.camel@sibyl.beware.dropbear.id.au>
	 <FBF34EE5-293D-43BC-93F8-4305F9312247@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 60-242-66-41.static.tpgi.com.au ([60.242.66.41]:39703 "EHLO
	sibyl.beware.dropbear.id.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760206AbZBDVl5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 16:41:57 -0500
In-Reply-To: <FBF34EE5-293D-43BC-93F8-4305F9312247@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2009-02-04 at 12:43 -0500, Chuck Lever wrote:
> Hi Ian-
> 
> On Feb 4, 2009, at Feb 4, 2009, 7:52 AM, Ian Dall wrote:
> > On Tue, 2009-02-03 at 17:16 -0500, Chuck Lever wrote:
> >> On Feb 3, 2009, at Feb 3, 2009, 4:56 PM, Ian Dall wrote:
> >>> OK here is version 2 of the patch. It is half the size of version 1,
> >>> although the resultant client.c is slightly bigger and IMO slightly
> >>> inferior than for version 1, but certainly it is around the margin.
> >>
> >> Why do you think this is inferior?  This way we are checking exactly
> >> the fields in each sockaddr that need to be checked, and using the
> >> same equality test that most other parts of the NFS client use.
> >
> > There is duplicated code, namely the function headers for
> > nfs_sockaddr_match_ipaddr() and nfs_sockaddr_match_port().
> >
> > Granted this doesn't add to the executable size in any way because of
> > the conditional compilation, but it is still a potential source of
> > trouble down the track when one function definition gets changed and
> > another doesn't and further more, it won't show up unless you test  
> > both
> > IPV6 and non IPV6 configurations. Having function headers in two  
> > places
> > makes following the code with etags more confusing. And even without
> > etags you have to scroll up and down to see the two versions of the  
> > same
> > function.
> >
> > Also nfs_sockaddr_match_ipaddr4() is trivial, taking 7 lines of code
> > (counting the call and the function definition) to do what can be
> > expressed in 2 and has additional overhead, albeit small.
> >
> > None of these are a big deal, which is way I said *slightly* inferior.
> >
> > I'm not exactly sure what you didn't like about my first patch.  
> > Maybe it
> > was just too big (fair enough, more to go wrong), or maybe you didn't
> > like the  test return; test return; ... style, or maybe you didn't  
> > like
> > the use of a port_match flag.
> 
> I think you are trying to address two separate issues here in a single  
> patch.  Replacing the memcmp() should be done in one patch, and any  
> code clean up should be done in a second.

Understood. It arose because I it affected the code I was introducing.
My original patch (on bugzilla, not this list) introduced a single
function to compare ports. Then after the conditional compilation was
added, I would have had to add two versions of the same function, which
seemed bad practice.


-- 
Ian Dall <ian-Xg6/AsmM8Z5B3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

