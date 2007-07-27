From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: wonky autotools question
Date: Fri, 27 Jul 2007 17:41:59 -0400
Message-ID: <46AA66A7.1050304@oracle.com>
References: <46AA4BF6.6090002@oracle.com> <20070727200856.GI13965@fieldses.org>
	<46AA52C0.8060209@oracle.com> <f606ea2d46f0.46a9f33f@usc.edu>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010901050005010306020001"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: Garrick Staples <garrick@usc.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IEXav-0000PT-93
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:43:33 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IEXay-0004Qd-Vj
	for nfs@lists.sourceforge.net; Fri, 27 Jul 2007 14:43:37 -0700
In-Reply-To: <f606ea2d46f0.46a9f33f@usc.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------010901050005010306020001
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Garrick Staples wrote:
> ----- Original Message -----
> From: Chuck Lever <chuck.lever@oracle.com>
> Date: Friday, July 27, 2007 1:19 pm
> Subject: Re: [NFS] wonky autotools question
> To: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: nfs@lists.sourceforge.net
> 
>> J. Bruce Fields wrote:
>>> On Fri, Jul 27, 2007 at 03:48:06PM -0400, Chuck Lever wrote:
>>>> Hi all-
>>>>
>>>> It would be nice to enable more static code checking in nfs-
>> utils (I'm 
>>>> especially interested in utils/mount/).  Is there a clean way to 
>> add 
>>>> additional CFLAGS, like -Wall, to utils/mount/Makefile using the 
>> autotools 
>>>> set up?  How about a lint or sparse target?
>>> I don't know, sounds like a good idea.
>> So far, "CFLAGS=-Wall -O2 -g ./configure" enables full warnings 
>> everywhere in the tree, but I haven't found anything on how to 
>> specify 
>> additional CFLAGS in one subdir, and have it happen automatically.
>>
>>> Last I checked, though, I thought there were still a fair number of
>>> warnings just with the current defaults.  Maybe we should fix 
>> those up
>>> first?
>> I'm focusing on utils/mount at the moment, and that seems pretty 
>> clean 
>> with the present C flags.  I have noticed warnings in other parts 
>> of the 
>> tree, but haven't had time to poke at them.
> 
> In configure.ac, add something like this:
>      GCC_WARNING_FLAGS="" 
>      if test "x$GCC" = "xyes" ;then
>         GCC_WARNING_FLAGS="-Wall -O2 -g"
>      fi
>      AC_SUBST(GCC_WARNING_FLAGS)
> 
> And then in utils/mount/Makefile.am, add something like this:
>    mount_CFLAGS = $(GCC_WARNING_FLAGS)
>   
> 
> This is a pretty generic answer because I haven't actually looked at
> the source tree to know if these are correct for your autotools stuff.
 > If you like, I can grab it and send you a patch.

This is pretty straightforward, plus gives us a generic tool that can be 
added to each subdirectory as we please.

Though really, it does make sense to set -Wall for the whole package. 
Would anyone mind if I sent a patch that did that?

--------------010901050005010306020001
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------010901050005010306020001
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------010901050005010306020001
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010901050005010306020001--
