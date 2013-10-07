Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50074 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753401Ab3JGPFL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Oct 2013 11:05:11 -0400
Date: Mon, 7 Oct 2013 11:05:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] pynfs: fix reporting of ignored tests
Message-ID: <20131007150507.GE18051@fieldses.org>
References: <1381004835-7485-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381004835-7485-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 05, 2013 at 10:27:15PM +0200, Tigran Mkrtchyan wrote:
> currently, ignored tests reported as failure, which
> makes fixing them quite hard.

Thanks.  And it's not counting warnings either?  I wonder if
printresults and xml_printresults should be sharing some code?

--b.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/testmod.py | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/nfs4.1/testmod.py b/nfs4.1/testmod.py
> index 3d74efe..68855de 100644
> --- a/nfs4.1/testmod.py
> +++ b/nfs4.1/testmod.py
> @@ -439,6 +439,7 @@ def printresults(tests, opts, file=None):
>  def xml_printresults(tests, file_name, suite='all'):
>      with open(file_name, 'w') as fd:
>          failures = 0
> +        skipped = 0
>          total_time = 0
>          doc = xml.dom.minidom.Document()
>          testsuite = doc.createElement("testsuite")
> @@ -455,14 +456,19 @@ def xml_printresults(tests, file_name, suite='all'):
>              testcase.setAttribute("time", str(t.time_taken))
>  
>              total_time += t.time_taken
> -            if t.result not in (TEST_PASS, TEST_WARN):
> +            if t.result == TEST_FAIL:
>                  failures += 1
>                  failure = doc.createElement("failure")
>                  failure.setAttribute("message", t.result.msg)
>                  err = doc.createCDATASection(''.join(t.result.tb))
>                  failure.appendChild(err)
>                  testcase.appendChild(failure)
> +            elif t.result == TEST_OMIT:
> +                skipped += 1
> +                skip = doc.createElement("skipped")
> +                testcase.appendChild(skip)
>  
>          testsuite.setAttribute("failures", str(failures))
> +        testsuite.setAttribute("skipped", str(skipped))
>          testsuite.setAttribute("time", str(total_time))
>          fd.write(doc.toprettyxml(indent="  "))
> -- 
> 1.8.3.1
> 
