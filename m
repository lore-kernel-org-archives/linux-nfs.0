From: Vince Busam <vbusam@google.com>
Subject: mtime not updated in client cache?
Date: Mon, 28 Nov 2005 16:09:40 -0800
Message-ID: <438B9C44.4030305@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Egt48-0005RW-Uo
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 16:09:48 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Egt47-0002Z6-KV
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 16:09:48 -0800
Received: from mail2.smo.corp.google.com (mail2.smo.corp.google.com [172.29.48.30])
	by smtp-out.google.com with ESMTP id jAT09hic024963
	for <nfs@lists.sourceforge.net>; Mon, 28 Nov 2005 16:09:43 -0800
Received: from [172.29.52.19] (dig.smo.corp.google.com [172.29.52.19])
	by mail2.smo.corp.google.com with ESMTP id jAT09e87031987
	for <nfs@lists.sourceforge.net>; Mon, 28 Nov 2005 16:09:41 -0800
To: nfs@lists.sourceforge.net
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

The following code snippet run on a 2.6.13.4 (+CITI patch) client shows that mtime doesn't 
get updated unless fclose() is called before stat, or O_DIRECT is used.  In 2.4, the stat 
would return an updated mtime.  Is this a bug, or expected cache behavior?

Thanks,
Vince

#include <stdio.h>
#include <time.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/stat.h>

int main(int argc, char **argv) {
   time_t tm;
   struct stat statinfo;
   FILE *fp = fopen("testfile", "w");
   sleep(2);
   tm = time(NULL);
   fwrite("X", 1, 1, fp);
   fflush(fp);

   stat("testfile", &statinfo);

   if (statinfo.st_mtime < tm) {
     printf("Bug: write time = %u, mtime = %u\n", tm, statinfo.st_mtime);
   }

   fclose(fp);
   return 0;
}


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
