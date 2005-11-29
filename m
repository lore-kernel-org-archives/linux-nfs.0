From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: mtime not updated in client cache?
Date: Mon, 28 Nov 2005 19:45:29 -0500
Message-ID: <1133225130.12178.9.camel@lade.trondhjem.org>
References: <438B9C44.4030305@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Egtcw-0008QF-EL
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 16:45:46 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Egtcr-0005ci-U5
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 16:45:46 -0800
To: Vince Busam <vbusam@google.com>
In-Reply-To: <438B9C44.4030305@google.com>
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

On Mon, 2005-11-28 at 16:09 -0800, Vince Busam wrote:
> The following code snippet run on a 2.6.13.4 (+CITI patch) client shows that mtime doesn't 
> get updated unless fclose() is called before stat, or O_DIRECT is used.  In 2.4, the stat 
> would return an updated mtime.  Is this a bug, or expected cache behavior?

That is a known issue that should be fixed in 2.6.15-rcX

Cheers,
  Trond

> Thanks,
> Vince
> 
> #include <stdio.h>
> #include <time.h>
> #include <sys/types.h>
> #include <unistd.h>
> #include <sys/stat.h>
> 
> int main(int argc, char **argv) {
>    time_t tm;
>    struct stat statinfo;
>    FILE *fp = fopen("testfile", "w");
>    sleep(2);
>    tm = time(NULL);
>    fwrite("X", 1, 1, fp);
>    fflush(fp);
> 
>    stat("testfile", &statinfo);
> 
>    if (statinfo.st_mtime < tm) {
>      printf("Bug: write time = %u, mtime = %u\n", tm, statinfo.st_mtime);
>    }
> 
>    fclose(fp);
>    return 0;
> }
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
> for problems?  Stop!  Download the new AJAX search engine that makes
> searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
> http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
