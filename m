Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59338 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751196AbeECKLd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 May 2018 06:11:33 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0685C40201AF
        for <linux-nfs@vger.kernel.org>; Thu,  3 May 2018 10:11:33 +0000 (UTC)
Message-ID: <1525342291.7550.16.camel@redhat.com>
Subject: Re: [PATCH 2/7] nfs-utils: Make config includes relative to current
 config
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 03 May 2018 11:11:31 +0100
In-Reply-To: <6f363a98-479a-8d7e-cbd5-bd5d7248f41d@RedHat.com>
References: <1524496788.7418.2.camel@redhat.com>
         <1524497125.7418.5.camel@redhat.com>
         <6f363a98-479a-8d7e-cbd5-bd5d7248f41d@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-05-02 at 14:21 -0400, Steve Dickson wrote:
> Hi Justin,
> 
> Sorry for taking so long to get to this... 
> 
> Most of my comments is about the style you are using.
> 
> I would like to keep the coding style somewhat the same 
> and in a few places that is not just not happening...

Yeah sorry I should have paid more attention to maintaining style,
will fix it all up and repost.

> >  /*
> >   * Parse the line LINE of SZ bytes.  Skip Comments, recognize section
> >   * headers and feed tag-value pairs into our configuration database.
> >   */
> >  static void
> > -conf_parse_line(int trans, char *line, int lineno, char **section, char **subsection)
> > +conf_parse_line(int trans, char *line, const char *filename, int lineno, char **section, char **subsection)
> >  {
> >  	char *val, *ptr;
> >  
> > @@ -366,10 +395,12 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
> >  
> >  	if (strcasecmp(line, "include")==0) {
> >  		/* load and parse subordinate config files */
> > -		char * subconf = conf_readfile(val);
> > +		char * relpath = relative_path(filename, val);
> > +		char * subconf = conf_readfile(relpath);
> Same here no space also isn't subconf being over written?
nope, conf_readfile() returns a malloced chunk that gets freed at the
end of the include handler


> > @@ -383,10 +414,11 @@ conf_parse_line(int trans, char *line, int lineno, char **section, char **subsec
> >  				inc_subsection = strdup(*subsection);
> >  		}
> >  
> > -		conf_parse(trans, subconf, &inc_section, &inc_subsection);
> > +		conf_parse(trans, subconf, &inc_section, &inc_subsection, relpath);
> >  
> >  		if (inc_section) free(inc_section);
> >  		if (inc_subsection) free(inc_subsection);
> > +		if (relpath) free(relpath);
> Are these if even needed? Won't these either be NULL or allocated memory?
yes, inc_section and inc_subsection are strdup()ed copies of the current
section titles because conf_parse() will alter them if any new section
headers are encountered, yet we needed to know what section we were in
when we entered this included conf file.

the way it is written will correctly handle recursive includes.

in general all my code changes are avoiding any use of globals and
statics in the hope of eventually making the code base thread-safe and
suitable for use as a public library, so that tends to mean more freeing
of short lived malloced chunks.

