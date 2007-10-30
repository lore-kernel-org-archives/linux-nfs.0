From: "Ruini Xue" <xueruini@gmail.com>
Subject: delay in seeing newly created files from nfs client
Date: Tue, 30 Oct 2007 17:13:07 +0800
Message-ID: <2bba2d6a0710300213i4c000f23x256e12eb5375a995@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1296886877=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Imn9s-0001Eb-Q7
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 02:13:12 -0700
Received: from nf-out-0910.google.com ([64.233.182.191])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Imn9y-0000uR-0E
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 02:13:18 -0700
Received: by nf-out-0910.google.com with SMTP id 4so5090630nfv
	for <nfs@lists.sourceforge.net>; Tue, 30 Oct 2007 02:13:13 -0700 (PDT)
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

--===============1296886877==
Content-Type: multipart/alternative;
	boundary="----=_Part_1214_9891748.1193735592533"

------=_Part_1214_9891748.1193735592533
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

I encounter some difficulties when testing file existence over NFS. I use
access("filename", F_OK) in a while-loop to test for the existence of
"filename", and there are two cases, but quit different results:
1. If the file is created on another node before the testing begins, then
the access() would success in a very short time (less than 0.001 sec), and
quit the while-loop. Otherwise,
1. If the file is created on another node after the test begins,  the
while-loop would last for quite a long time (about 20~30 sec) until the
access() returns ok.

I think this is not so related to 'noac', and I can not figure out what
makes them different. The NFS server/client are configured with default
options. Is there a safety method to test the existence of a newly created
file?

BTW, I am not in the list, please cc to me if you reply. Thanks!

Best

Andrew

Below is my testing code:
/****************************************************
 * fexist.c
 * gcc -o fexit fexit.c
 *
 * test cases: (before the test, make sure no file 'test' exist)
 * 1. on one node create a file `test', then run `fexit' on another node
(returns in l sec)
 * 2. run `fexit' in one node at first, and then creat file 'test' on
another (returns in 20~30 sec)
*/
#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/stat.h>

static double gettime()
{
    struct timeval tp;

    gettimeofday(&tp, NULL);

    return ((double)tp.tv_sec + tp.tv_usec * 1e-6);
}

static int file_exist(const char* path)
{
    struct stat sbuf;
    return access(path, F_OK);
}


int main()
{
    double s, e;
    s = gettime();
    while (file_exist("./test") != 0);
    e = gettime();

    printf("Wait: %f\n", e - s);

    return 0;
}

------=_Part_1214_9891748.1193735592533
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,<br><br>I encounter some difficulties when testing file existence over NFS. I use access(&quot;filename&quot;, F_OK) in a while-loop to test for the existence of &quot;filename&quot;, and there are two cases, but quit different results:
<br>1. If the file is created on another node before the testing begins, then the access() would success in a very short time (less than 0.001 sec), and quit the while-loop. Otherwise,<br>1. If the file is created on another node after the test begins,&nbsp; the while-loop would last for quite a long time (about 20~30 sec) until the access() returns ok.
<br><br>I think this is not so related to &#39;noac&#39;, and I can not figure out what makes them different. The NFS server/client are configured with default options. Is there a safety method to test the existence of a newly created file?
<br><br>BTW, I am not in the list, please cc to me if you reply. Thanks! <br><br>Best<br><br>Andrew<br><br>Below is my testing code:<br>/****************************************************<br>&nbsp;* fexist.c<br>&nbsp;* gcc -o fexit 
fexit.c<br>&nbsp;*<br>&nbsp;* test cases: (before the test, make sure no file &#39;test&#39; exist)<br>&nbsp;* 1. on one node create a file `test&#39;, then run `fexit&#39; on another node (returns in l sec)<br>&nbsp;* 2. run `fexit&#39; in one node at first, and then creat file &#39;test&#39; on another (returns in 20~30 sec)
<br>*/<br>#include &lt;stdio.h&gt;<br>#include &lt;unistd.h&gt;<br>#include &lt;sys/time.h&gt;<br>#include &lt;sys/types.h&gt;<br>#include &lt;sys/stat.h&gt;<br><br>static double gettime()<br>{&nbsp;&nbsp; <br>&nbsp;&nbsp;&nbsp; struct timeval tp;
<br><br>&nbsp;&nbsp;&nbsp; gettimeofday(&amp;tp, NULL);<br>&nbsp;&nbsp;&nbsp; <br>&nbsp;&nbsp;&nbsp; return ((double)tp.tv_sec + tp.tv_usec * 1e-6);<br>}<br><br>static int file_exist(const char* path)<br>{<br>&nbsp;&nbsp;&nbsp; struct stat sbuf;<br>&nbsp;&nbsp;&nbsp; return access(path, F_OK);<br>
}<br><br><br>int main()<br>{<br>&nbsp;&nbsp;&nbsp; double s, e;<br>&nbsp;&nbsp;&nbsp; s = gettime(); <br>&nbsp;&nbsp;&nbsp; while (file_exist(&quot;./test&quot;) != 0);<br>&nbsp;&nbsp;&nbsp; e = gettime();<br><br>&nbsp;&nbsp;&nbsp; printf(&quot;Wait: %f\n&quot;, e - s);<br><br>&nbsp;&nbsp;&nbsp; return 0;<br>}
<br><br><br><br>

------=_Part_1214_9891748.1193735592533--


--===============1296886877==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1296886877==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1296886877==--
