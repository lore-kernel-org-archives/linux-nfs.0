Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from oxalide-out.extra.cea.fr ([132.168.224.1]:33296 "EHLO
	oxalide-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752650Ab1AYK3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 05:29:30 -0500
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by oxalide.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id p0P9kXXE018482
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 25 Jan 2011 10:46:33 +0100
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id p0P9kXeE007360
	for <linux-nfs@vger.kernel.org>; Tue, 25 Jan 2011 10:46:33 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id p0P9kXRO012928
	for <linux-nfs@vger.kernel.org>; Tue, 25 Jan 2011 10:46:33 +0100
Message-ID: <4D3E9BF9.7080406@cea.fr>
Date: Tue, 25 Jan 2011 10:46:33 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: Thomas Haynes <thomas@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Patched up cthon source?
References: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
In-Reply-To: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thomas Haynes a écrit :
> I'm being evil here on purpose. :->
>
> I'm trying to run cthon04 as downloaded from the connectathon.org repository
> and I'm getting this:
>
>
> Nroff
> ./stat: no data in nroff.time
> general tests failed
> Tests failed, leaving /cthon04/loghyr mounted
>
>   
I had a similar behavior and it was a bug on my side that I solved 
during the past bake-a-thom : the 'nroff' step does lots  of garbage  in 
the file, so there is a call to 'grep -v' to get rid off all this 
garbage. The result is sent to a secondary file that is moved to the 
original file. So there is a 'mv -f a b' were both a and b exist. This 
should lead to a situation were the original "b" disappears and is 
replaced by "a". This was the bug I had. May be you are in the same 
situation. I hope this would help you.

    Regards

       Philippe
