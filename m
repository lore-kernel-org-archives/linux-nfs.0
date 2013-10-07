Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:44312 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751576Ab3JGRr7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Oct 2013 13:47:59 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id B9EDC28043A
	for <linux-nfs@vger.kernel.org>; Mon,  7 Oct 2013 19:47:58 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id A8F9F10FF
	for <linux-nfs@vger.kernel.org>; Mon,  7 Oct 2013 19:47:58 +0200 (MEST)
Date: Mon, 7 Oct 2013 19:47:58 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Message-ID: <926019798.530894.1381168078530.JavaMail.zimbra@desy.de>
In-Reply-To: <20131007150507.GE18051@fieldses.org>
References: <1381004835-7485-1-git-send-email-tigran.mkrtchyan@desy.de> <20131007150507.GE18051@fieldses.org>
Subject: Re: [PATCH] pynfs: fix reporting of ignored tests
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Cc: linux-nfs@vger.kernel.org
> Sent: Monday, October 7, 2013 5:05:07 PM
> Subject: Re: [PATCH] pynfs: fix reporting of ignored tests
> 
> On Sat, Oct 05, 2013 at 10:27:15PM +0200, Tigran Mkrtchyan wrote:
> > currently, ignored tests reported as failure, which
> > makes fixing them quite hard.
> 
> Thanks.  And it's not counting warnings either?  I wonder if

The JUnit format does not have WARN. I can count them as failed.
> printresults and xml_printresults should be sharing some code?

I can will check how code duplication can be reduced as well as make
nfsv4.0 able to use it as well.

Tigran.
> 
> --b.
> 
> > 
> > Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> > ---
> >  nfs4.1/testmod.py | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> > 
> > diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
> > index 3d74efe..68855de 100644
> > --- a/nfs4.1/testmod.py
> > +++ b/nfs4.1/testmod.py
> > @@ -439,6 +439,7 @@ def printresults(tests, opts, file=None):
> >  def xml_printresults(tests, file_name, suite='all'):
> >      with open(file_name, 'w') as fd:
> >          failures = 0
> > +        skipped = 0
> >          total_time = 0
> >          doc = xml.dom.minidom.Document()
> >          testsuite = doc.createElement("testsuite")
> > @@ -455,14 +456,19 @@ def xml_printresults(tests, file_name, suite='all'):
> >              testcase.setAttribute("time", str(t.time_taken))
> >  
> >              total_time += t.time_taken
> > -            if t.result not in (TEST_PASS, TEST_WARN):
> > +            if t.result == TEST_FAIL:
> >                  failures += 1
> >                  failure = doc.createElement("failure")
> >                  failure.setAttribute("message", t.result.msg)
> >                  err = doc.createCDATASection(''.join(t.result.tb))
> >                  failure.appendChild(err)
> >                  testcase.appendChild(failure)
> > +            elif t.result == TEST_OMIT:
> > +                skipped += 1
> > +                skip = doc.createElement("skipped")
> > +                testcase.appendChild(skip)
> >  
> >          testsuite.setAttribute("failures", str(failures))
> > +        testsuite.setAttribute("skipped", str(skipped))
> >          testsuite.setAttribute("time", str(total_time))
> >          fd.write(doc.toprettyxml(indent="  "))
> > --
> > 1.8.3.1
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
