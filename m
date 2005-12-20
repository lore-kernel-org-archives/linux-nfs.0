From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: Re: nfs-utils 1.0.8-rc2
Date: Tue, 20 Dec 2005 11:17:19 +0100
Message-ID: <43A7DA2F.8090902@ext.bull.net>
References: <17314.22172.913247.595571@cse.unsw.edu.au> <17319.46982.772021.518625@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EoeXe-0000Wc-OK
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 02:16:22 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EoeXa-0006RH-Hl
	for nfs@lists.sourceforge.net; Tue, 20 Dec 2005 02:16:22 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17319.46982.772021.518625@cse.unsw.edu.au>
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

Hi Neil,

There is a problem in rquotad compilation when compiling nfs-utils on a=20
SLES 9 for ppc64:

Making all in rquotad
make[2]: Entering directory `/usr/src/nfs-utils-1.0.8-rc2/utils/rquotad'
if gcc -DHAVE_CONFIG_H -I. -I. -I../../support/include =20
-I../../support/include -D_FILE_OFFSET_BITS=3D64 -D_GNU_SOURCE=20
-I../../support/export -D_GNU_SOURCE -Wall  -pipe -g -O2 -MT=20
rquotad-rquota_server.o -MD -MP -MF ".deps/rquotad-rquota_server.Tpo" -c=20
-o rquotad-rquota_server.o `test -f 'rquota_server.c' || echo=20
'./'`rquota_server.c; \
then mv -f ".deps/rquotad-rquota_server.Tpo"=20
".deps/rquotad-rquota_server.Po"; else rm -f=20
".deps/rquotad-rquota_server.Tpo"; exit 1; fi
rquota_server.c: In function `getquotainfo':
rquota_server.c:78: error: storage size of `dq_dqb' isn't known
rquota_server.c:146: warning: implicit declaration of function `dqoff'
rquota_server.c:147: error: invalid application of `sizeof' to an=20
incomplete type
rquota_server.c:153: error: invalid application of `sizeof' to an=20
incomplete type
rquota_server.c:155: error: invalid application of `sizeof' to an=20
incomplete type
rquota_server.c:155: error: duplicate case value
rquota_server.c:148: error: previously used here
rquota_server.c:78: warning: unused variable `dq_dqb'

In sys/quota.h :

struct dqblk
  {
    u_int32_t dqb_bhardlimit;   /* absolute limit on disk blks alloc */
    u_int32_t dqb_bsoftlimit;   /* preferred limit on disk blks */
    u_int32_t dqb_curblocks;    /* current block count */
    u_int32_t dqb_ihardlimit;   /* maximum # allocated inodes */
    u_int32_t dqb_isoftlimit;   /* preferred inode limit */
    u_int32_t dqb_curinodes;    /* current # allocated inodes */
    time_t dqb_btime;           /* time limit for excessive disk use */
    time_t dqb_itime;           /* time limit for excessive files */
  };

Is replaced by that structure on a SLES9 ppc64:

struct if_dqblk {
        u_int64_t dqb_bhardlimit;
        u_int64_t dqb_bsoftlimit;
        u_int64_t dqb_curspace;
        u_int64_t dqb_ihardlimit;
        u_int64_t dqb_isoftlimit;
        u_int64_t dqb_curinodes;
        u_int64_t dqb_btime;
        u_int64_t dqb_itime;
        u_int32_t dqb_valid;
};

It is not a new problem, it had also occured with nfs-utils-1.0.7.

Aur=E9lien



Neil Brown wrote:

>On Friday December 16, neilb@suse.de wrote:
> =20
>
>>I have just make a RC release for nfs-utils.
>>nfs-utils-1.0.8-rc1 can be found at
>>
>>  http://sourceforge.net/project/showfiles.php?group_id=3D14
>>or (soon) at
>>  http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/
>>   =20
>>
>
>Now there is an -rc2.=20
>It has a large update to the autoconf infrastructure.=20
>It would be helpful to know that it builds successfully in various
>configurations on various distributions.
>Please report any problems.
>
>Thanks,
>NeilBrown
>
>
>-------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc. Do you grep through log f=
iles
>for problems?  Stop!  Download the new AJAX search engine that makes
>searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
>http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
> =20
>



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
