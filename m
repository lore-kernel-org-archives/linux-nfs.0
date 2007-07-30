From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 15/23] mount.nfs: clean up getport() function
Date: Sun, 29 Jul 2007 22:33:44 -0400
Message-ID: <46AD4E08.7020306@oracle.com>
References: <20070728215024.21871.54208.stgit@localhost.localdomain>
	<20070729234333.GA18686@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030404030103070408060601"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFL64-0000N2-Mk
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 19:35:00 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFL67-0002MQ-9V
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 19:35:04 -0700
In-Reply-To: <20070729234333.GA18686@fieldses.org>
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
--------------030404030103070408060601
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Sat, Jul 28, 2007 at 05:50:24PM -0400, Chuck Lever wrote:
>> Mostly comment clarification.  Also replace some naked undocumented
>> integers with macros, and make getport() static.
>> @@ -153,25 +157,30 @@ unsigned short getport(struct sockaddr_in *saddr, unsigned long prog,
>>  		return 0;
>>  	}
>>  
>> -	switch (prot) {
>> +	switch (proto) {
>>  	case IPPROTO_UDP:
>>  		clnt = clntudp_bufcreate(saddr,
>> -					 PMAPPROG, PMAPVERS, TIMEOUT, &socket,
>> -					 UDPMSGSIZE, UDPMSGSIZE);
>> +					 PMAPPROG, PMAPVERS,
>> +					 RETRY_TIMEOUT, &socket,
>> +					 RPCSMALLMSGSIZE,
>> +					 RPCSMALLMSGSIZE);
>>  		break;
>>  	case IPPROTO_TCP:
>> -		clnt = clnttcp_create(saddr,
>> -			PMAPPROG, PMAPVERS, &socket, 50, 500);
>> +		clnt = clnttcp_create(saddr, PMAPPROG, PMAPVERS, &socket,
>> +				      RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
> 
> Did you mean to change those final two arguments?  (They were different
> before, then they're the same after.)

They now match the code in support/nfs/conn.c:clnt_ping().

--------------030404030103070408060601
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
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------030404030103070408060601
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------030404030103070408060601
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030404030103070408060601--
