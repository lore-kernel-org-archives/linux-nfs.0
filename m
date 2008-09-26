From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 17:11:25 -0400
Message-ID: <215DBAD9-1E4B-4E23-9F54-AAF6518D24DA@oracle.com>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net> <20080925213831.GF14349@fieldses.org> <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com> <20080926184554.GA1492@fieldses.org> <1222454975.10150.8.camel@localhost> <EF58CFE4-3F4B-4985-9DEA-E61CC0DFC8EA@oracle.com> <1222456290.10150.10.camel@localhost> <20080926194421.GD1492@fieldses.org> <87089E47-10AE-4D41-B5BE-CCEE034C526B@oracle.com> <1222459067.10150.16.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:10954 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbYIZVLo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 17:11:44 -0400
In-Reply-To: <1222459067.10150.16.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at Sep 26, 2008, 3:57 PM, Trond Myklebust wrote:
> On Fri, 2008-09-26 at 15:54 -0400, Chuck Lever wrote:
>> The whole system makes it absolutely impossible to plan features and
>> bug fixes.
>
> The only thing it makes impossible is planning features for a
> _particular_ kernel revision.

I find it impossible to plan for a particular _year_ (or even two).

The problem is _you_, the subsystem maintainer, have a merge window  
too.  I find it challenging to align my patch submissions with two  
sliding merge windows that open and close at arbitrary times without  
any warning whatever.  And now I have to worry about Bruce's merge  
window as well....

Plus, the submission guidelines keep changing.  FreeBSD has an amazing  
guide to kernel development rules and conventions posted on the web.   
I wish Linux had the same.

If I know in advance when you (and Bruce) are taking new features or  
bug fixes for each kernel release, that would be helpful.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
