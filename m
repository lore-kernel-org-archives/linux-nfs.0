From: Omry Yadan <omry-FZzTFxfWWV5eoWH0uzbU5w@public.gmane.org>
Subject: Re: file open for write fails under stress
Date: Tue, 14 Oct 2008 19:59:54 +0200
Message-ID: <48F4DE1A.3090809@yadan.net>
References: <48F3D106.9020203@yadan.net> <20081014171032.GA17899@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out6.bezeqint.net ([192.115.188.206]:41550 "EHLO
	out6.bezeqint.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbYJNSAO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Oct 2008 14:00:14 -0400
In-Reply-To: <20081014171032.GA17899@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

> On Tue, Oct 14, 2008 at 12:51:50AM +0200, Omry Yadan wrote:
>   
>> I have an application that open many files for writing very fast, in a
>> way - it can almost be looked as a file system stress test.
>>
>>
>> my application is single threaded, and I noticed the following problem
>> when running a single instance of it:
>>
>>
>> at some point, after opening (and closing) many files for writing, the
>> application fails to open a file for writing.
>>     
>
> Do you know what error exactly the open is failing with?
>   
As I wrote in a separate message to the list:
the error string is "Input Output error".
I can get the exact errno if you like, but it's probably a generic IO
error code.
