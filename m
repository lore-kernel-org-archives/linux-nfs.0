From: ramana <ramana@intraperson.com>
Subject: Re: Autodir and nfs
Date: Tue, 16 Nov 2004 07:28:11 +0530
Message-ID: <41995EB3.40702@intraperson.com>
References: <4196DB26.9040207@intraperson.com>	 <1100451447.11340.2.camel@lade.trondhjem.org>	 <1100451550.11340.4.camel@lade.trondhjem.org>	 <41985E2A.2060000@intraperson.com> <1100533463.11246.3.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CTsXn-00022c-1l
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 17:54:07 -0800
Received: from smtp.net4india.com ([202.71.128.225])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CTsXm-0003Ih-2y
	for nfs@lists.sourceforge.net; Mon, 15 Nov 2004 17:54:06 -0800
Received: from [202.63.116.2] (helo=intraperson.com)
	by smtp.net4india.com with esmtp (Exim 3.36 #1)
	id 1CTsjf-0004du-00
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 07:36:23 +0530
To: nfs@lists.sourceforge.net
In-Reply-To: <1100533463.11246.3.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Trond Myklebust wrote:

>må den 15.11.2004 Klokka 13:13 (+0530) skreiv ramana:
>
>  
>
>>It does not work when whole /home exported like this.
>>/home          127.0.0.1(rw)
>>
>>Becuase NFS does not see any dirs within /home dir because of the way 
>>Autodir works.
>>
>>It works when individual home dirs exported like this.
>>/home/t1000     127.0.0.1(rw)
>>    
>>
>
>Probably because user "nobody" does not have access to /home on the
>server. RTFM about root squashing...
>
>Cheers,
>  Trond
>
>  
>
I appreciate your time. You can not solve it from man page.

Regards
ramana

-- 
http://www.intraperson.com





-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
