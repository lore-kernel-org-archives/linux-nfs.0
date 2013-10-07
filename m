Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:43136
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755130Ab3JGQGY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Oct 2013 12:06:24 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Tigran Mkrtchyan'" <tigran.mkrtchyan@desy.de>
Cc: <linux-nfs@vger.kernel.org>
References: <1381004835-7485-1-git-send-email-tigran.mkrtchyan@desy.de> <20131007150507.GE18051@fieldses.org>
In-Reply-To: <20131007150507.GE18051@fieldses.org>
Subject: RE: [PATCH] pynfs: fix reporting of ignored tests
Date: Mon, 7 Oct 2013 09:05:08 -0700
Message-ID: <00e001cec377$0e814340$2b83c9c0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tigran,

You also modified DSESS9005, should that actually be split into two separate
test cases?

Hmm, looks like a set of 4.1 tests that are not part of all that I need to
see how they fare against Ganesha.

Frank

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Monday, October 7, 2013 8:05 AM
> To: Tigran Mkrtchyan
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH] pynfs: fix reporting of ignored tests
> 
> On Sat, Oct 05, 2013 at 10:27:15PM +0200, Tigran Mkrtchyan wrote:
> > currently, ignored tests reported as failure, which makes fixing them
> > quite hard.
> 
> Thanks.  And it's not counting warnings either?  I wonder if printresults
and
> xml_printresults should be sharing some code?
> 
> --b.
> 
> >
> > Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> > ---
> >  nfs4.1/testmod.py | 8 +++++++-
> >  1 file changed, 7 insertions(+), 1 deletion(-)
> >
> > diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py index
> > 3d74efe..68855de 100644
> > --- a/nfs4.1/testmod.py
> > +++ b/nfs4.1/testmod.py
> > @@ -439,6 +439,7 @@ def printresults(tests, opts, file=None):
> >  def xml_printresults(tests, file_name, suite='all'):
> >      with open(file_name, 'w') as fd:
> >          failures = 0
> > +        skipped = 0
> >          total_time = 0
> >          doc = xml.dom.minidom.Document()
> >          testsuite = doc.createElement("testsuite") @@ -455,14 +456,19
> > @@ def xml_printresults(tests, file_name, suite='all'):
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
the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html

