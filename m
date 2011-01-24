Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43422 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878Ab1AXWZd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jan 2011 17:25:33 -0500
Subject: Re: Patched up cthon source?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
Date: Mon, 24 Jan 2011 17:24:57 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <83EC814B-1043-46B2-8F5E-E1FB1F5B56BF@oracle.com>
References: <E5AAF04F-8A0E-4506-A29D-A0CD4098AA64@netapp.com>
To: Thomas Haynes <thomas@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 24, 2011, at 5:19 PM, Thomas Haynes wrote:

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
> As I kinda recall several people fixing this already, where would I go to get patches?

What are your CFLAGS settings in tests.init?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




