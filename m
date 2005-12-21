From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: Re: nfs-utils 1.0.8-rc2
Date: Wed, 21 Dec 2005 10:38:57 +0100
Message-ID: <43A922B1.3090809@ext.bull.net>
References: <17314.22172.913247.595571@cse.unsw.edu.au>	<17319.46982.772021.518625@cse.unsw.edu.au>	<43A7DA2F.8090902@ext.bull.net>	<17320.50441.923081.501789@cse.unsw.edu.au> <17320.51818.921672.429852@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ep0Q0-0002qs-Fj
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 01:37:56 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ep0Pz-0004rO-4q
	for nfs@lists.sourceforge.net; Wed, 21 Dec 2005 01:37:56 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17320.51818.921672.429852@cse.unsw.edu.au>
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

Neil Brown wrote:

>On Wednesday December 21, neilb@suse.de wrote:
> =20
>
>>I guess I'd better fix it....
>>
>Does this patch
>  a/ look ok (if a bit heavy handed).
>  b/ compile for you?
> =20
>
That is OK for that part

There is another problem for the compilation of hasquota.c, because=20
QUOTAFILENAME definition is missing in sys/quota.h

#define QUOTAFILENAME "quota"
is needed to compile

Thanks,

Aur=E9lien


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
