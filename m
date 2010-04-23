Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54354 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517Ab0DWULS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Apr 2010 16:11:18 -0400
Message-ID: <4BD1FE77.1050000@oracle.com>
Date: Fri, 23 Apr 2010 16:09:27 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: Mike Frysinger <vapier@gentoo.org>
CC: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] make capabilities support optional
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD1E55B.2090703@RedHat.com> <4BD1F121.1060001@oracle.com> <201004231529.42370.vapier@gentoo.org>
In-Reply-To: <201004231529.42370.vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/23/2010 03:29 PM, Mike Frysinger wrote:
> On Friday 23 April 2010 15:12:33 Chuck Lever wrote:
>> If we really do need to drop libcap for some configurations, then such a
>> change should be thoroughly tested in those environments.  Some features
>> won't always work without libcap, and appropriate warnings should be
>> added to man pages and/or should be displayed by statd.
>
> there should be appropriate documentation regardless.  current nfs-utils lists
> no information at all in ChangeLog/NEWS/README/INSTALL or any other document
> explaining why/what/how libcap is needed/used.  you cant do documentless dumps
> on distro maintainers and expect them to "just know" what is going on.

"git log" has served as the ChangeLog for some time now.  The commits I 
referenced in my last e-mail explain exactly why libcap was introduced.

You can also use "git annotate <some file>" to see exactly when 
particular lines of code were introduced or change, who changed them, 
and what git commit you can look at for more information.

The nfs-utils git repo is available on linux-nfs.org, and gitweb can 
guide you through all of this information with a nice GUI.

If all of that fails, you can still post a question here on this mailing 
list.

> this
> isnt the first time the nfs related packages suddenly started requiring new
> libraries out of the blue when in reality things could be done optionally, nor
> is this the first patch ive sent to try and address what appears to be
> unnecessarily hard deps.  kerberos readily comes to mind.

Patches are posted on this mailing list for review before they are 
committed.  Anyone has a chance to object, comment, or suggest a simpler 
way to do things.

Of course, that only works if you post to this list too.  I don't see 
this patch in the mailing list archives, but I may have missed something.

It's important to realize that it's much harder to make things optional 
than to insist that they be built in.  Adding build options means 
there's more work for distributors to configure the build, and it 
exponentially increases our test matrix (which is already out of 
control).  Every change now has to be tested with each combination of 
build options.  Add one more --enable option, and that doubles the 
number of combinations.

I don't have a problem with making new features optional, when it's 
necessary.  What I'm objecting to here is that it's easy to add 
autotools machinery, but it's a lot more difficult to check that all of 
nfs-utils still works in all cases after such a change, and that the new 
option doesn't introduce a regression (which it does in this case).

I didn't see a clear explanation of why your proposed change was 
necessary, nor was it clear from the patch description that you 
understood why libcap was added in the first place, nor does it seem 
that the regressions caused by disabling libcap are adequately addressed.

So, why do you want to make libcap optional?  And why is yet another 
build option needed (rather than just using AC_FUNCTIONS and HAVE_LIBCAP) ?

-- 
chuck[dot]lever[at]oracle[dot]com
