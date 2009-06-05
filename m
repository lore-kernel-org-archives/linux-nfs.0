From: Steve Dickson <SteveD@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Fri, 05 Jun 2009 14:14:12 -0400
Message-ID: <4A296074.2010207@RedHat.com>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <20090605161027.GF10975@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37552 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876AbZFESRO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 14:17:14 -0400
In-Reply-To: <20090605161027.GF10975@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Fri, Jun 05, 2009 at 07:36:48AM -0400, Jeff Layton wrote:
>> Eventually, we most distros are going to want to build nfs-utils
>> against libtirpc in order to get IPv6 support. At some point, we'll
>> probably want to make building with IPv6 support the default. In the
>> meantime however, we need to get more testing exposure for the TI-RPC
>> codepaths. We'll probably start building Fedora's nfs-utils with TI-RPC
>> support in the near future.
>>
>> The question that Steve D. has asked is whether we should also make
>> --enable-tirpc the default for the mainline nfs-utils tree?
>>
>> Doing this now would add wider testing exposure for these codepaths and
>> help flush out bugs in TIRPC+IPV4 codepaths. OTOH, it means adding a
>> new library dependency for packagers, or they'll need to take the
>> conscious step to --disable-tirpc when they configure.
>>
>> We could make it so that configure looks for libtirpc and if it's not
>> available, configures the build against legacy RPC interfaces. I think
>> this is a bad idea however. While it should "just work" either way,
>> there are some small behavioral differences when TIRPC support is built
>> in. I think it's probably better to make enabling and disabling TIRPC a
>> conscious step.
>>
>> Thoughts?
> 
> Makes sense to me to have upstream defaults set to what we expect
> distributions to move to, assuming there aren't known regressions.
I have to agree with this... Unstable code is unstable code and has to
be fixed _regardless_ of where it happens to be... Upstream, Rawhide
or Untested... 

My main concern is enabling tirpc by default is forcing other distros 
to incorporate libtirpc into their world which they may or may not want
to do... 

Very recently we've fixed the known licenses issues, and both
Chuck and Jeff have done a ton of work to enable IPv6 using the 
library and finally it does wean us away from the unchangeable 
glibc rpc code... 

But making a decency on it should not be taken lightly... IMHO... 
That's why I wanted the other distro to weigh in before the 
change is made...

steved
 

 
 
