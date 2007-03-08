From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Sign Extentions with Tru64 FSIDs.
Date: Wed, 07 Mar 2007 22:08:07 -0500
Message-ID: <45EF7E17.5010304@oracle.com>
References: <45EC7F0F.4090600@RedHat.com>		<1173130678.6315.7.camel@heimdal.trondhjem.org>		<45EC8FD3.4010809@redhat.com>		<1173132182.6315.27.camel@heimdal.trondhjem.org>		<45EC9837.1010504@redhat.com>	<1173186308.6393.7.camel@heimdal.trondhjem.org>	<45ED8135.2010008@RedHat.com>	<45EDE060.3020501@RedHat.com>
	<45EECE74.6070606@oracle.com> <45EEE863.4090202@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000306040404000506080406"
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>,
	Steve Dickson <SteveD@redhat.com>
To: Peter Staubach <staubach@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPFLp-0005I0-M3
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 01:55:58 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPFLp-00012Y-Je
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 01:55:59 -0800
In-Reply-To: <45EEE863.4090202@redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------000306040404000506080406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Peter Staubach wrote:
> Chuck Lever wrote:
>> A comment...
>>
>> You've implemented a "negative" -- the usual convention is to 
>> implement the "positive" option.   This is how Apple/*BSD do it for 
>> READDIRPLUS, and it might be good to follow existing precedent.
>>
>> I think you should implement "rddirplus" and make it the default.  
>> That way you get "norddirplus" automatically.
>>
>> You should also include appropriate man page changes in your patch. ;-D
>>
> 
> If "rddirplus" is the option and is the default, how do you turn it off?

The way you turn off cto, lock, and intr:  by preceding it with a "no".

--------------000306040404000506080406
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture Linux Projects Group
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------000306040404000506080406
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------000306040404000506080406
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------000306040404000506080406--
