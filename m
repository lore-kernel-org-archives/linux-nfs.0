From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Patch 3/8] NFS Mount Configuration File (Vers 2)
Date: Wed, 5 Aug 2009 15:33:16 -0400
Message-ID: <20090805193316.GJ9944@fieldses.org>
References: <4A76F8E6.2010607@RedHat.com> <4A76F9E9.5020604@RedHat.com> <20090803152409.GB28838@fieldses.org> <4A7706E8.7060106@RedHat.com> <20090803155658.GF28838@fieldses.org> <4A79DA03.20703@RedHat.com> <20090805192919.GI9944@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54039 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750845AbZHETdP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Aug 2009 15:33:15 -0400
In-Reply-To: <20090805192919.GI9944@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2009 at 03:29:19PM -0400, J. Bruce Fields wrote:
> On Wed, Aug 05, 2009 at 03:14:11PM -0400, Steve Dickson wrote:
> > After thinking about this.. I've convinced myself that the internal
> > parsing routines should make the Section names case-insensitive 
> > but the rest of the data (i.e the tag, value) should be returned as is
> > and let the callers deal with the case... 
> > 
> > The reason being everything hangs off Section names. So making those
> > easier to find I think is a good thing and hopefully it will make
> > managing config files a bit less error prone.... 
> 
> That's probably not what I would do, but I could live with that, as long
> as we're preserving the case of paths and user/group names.
> 
> By the way, it looks like the git code to handle their extended section
> names (the [key "string"] thing) is in git's
> config.c:get_extended_base_var(), if that's a useful example.

(And, by the way, they agree with you on case-sensitivity: from the
git-config man page:

	"The file consists of sections and variables. A section begins
	with the name of the section in square brackets and continues
	until the next section begins. Section names are not case
	sensitive. Only alphanumeric characters, - and . are allowed in
	section names. Each variable must belong to some section, which
	means that there must be section header before first setting of
	a variable.

	"Sections can be further divided into subsections. To begin a
	subsection put its name in double quotes, separated by space
	from the section name, in the section header, like in example
	below:

		[section "subsection"]

	"Subsection names can contain any characters except newline
	(doublequote " and backslash have to be escaped as \" and \\,
	respectively) and are case sensitive. Section header cannot span
	multiple lines."

)

--b.
