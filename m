Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9096 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751277AbeEVSXv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 May 2018 14:23:51 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4961C30BA1E7
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2018 18:23:51 +0000 (UTC)
Subject: Re: [PATCH v3 0/8] nfs-utils: nfsconf cli tool and code tests
To: Justin Mitchell <jumitche@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1526399410.7441.4.camel@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <06652e97-983b-77cd-c7b6-0ccaeeda788c@RedHat.com>
Date: Tue, 22 May 2018 14:23:50 -0400
MIME-Version: 1.0
In-Reply-To: <1526399410.7441.4.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/15/2018 11:50 AM, Justin Mitchell wrote:
> Apologies for the noise, I missed some files out when I last
> reposted, so here is an updated and tested version.
> 
> v3
> Include files that were missed out of v2
> Add the man page for nfsconftool
> 
> v2
> Updated style and commenting to make the code clearer
> 
> v1
> This series introduces a new cli tool to nfs-utils which provides
> for the dumping of the current configuration, querying of individual
> settings in a scripting friendly manner and by extention the 
> scripted testing and verification of nfsconf functionality.
> 
> The previously unreferenced conf_report() is modified to produce
> a sorted output, which allows you to --dump the current config in
> a way thats easier to diff
> 
> As well as some improved error messages a script is included which
> tests the current config parsing code by supplying various example
> config files and comparing the results of the --dump output.
> 
> The cli tool also allows a simple test to check if a config item
> has been set, and to retrieve the current value in a way that is
> easy to call from a shell script.
> 
> As the next stage I hope to impliment config setting via the cli 
> tool in order to provide an api for automation and management tools
> 
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
> 
> 
The series was committed with the name change... Thank you!

steved.
