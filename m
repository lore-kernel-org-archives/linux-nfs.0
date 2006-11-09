From: "Jiancong Xie" <jianc.xie@gmail.com>
Subject: errors in mount flags
Date: Thu, 9 Nov 2006 19:10:43 +0800
Message-ID: <7da130e0611090310v1b53351em560c40a0047a88c5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1384000070=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi7o1-0004TQ-Np
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 03:10:49 -0800
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gi7o1-0006Oy-AW
	for nfs@lists.sourceforge.net; Thu, 09 Nov 2006 03:10:50 -0800
Received: by ug-out-1314.google.com with SMTP id z38so187583ugc
	for <nfs@lists.sourceforge.net>; Thu, 09 Nov 2006 03:10:44 -0800 (PST)
To: nfs@lists.sourceforge.net
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

--===============1384000070==
Content-Type: multipart/alternative;
	boundary="----=_Part_36576_28130262.1163070643671"

------=_Part_36576_28130262.1163070643671
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

 Hi ,
    I wrote a programme to use the mount api to access the remote NFS
server. But after read the (man 2 mount), I found i cannot find a way to
achieve the goal. My problem is I donot know the mount api arguments been
set correctly .
    This error is very funny. Because when i executed the file , some times
it works ,but at most time, It failed.

I added my file following:


#include <sys/mount.h>
#include <linux/fs.h>
#include <stdio.h>
#include <sys/param.h>

static char *target="/mnt/gt11server";
static char *source="192.168.0.11:/mnt/ramdisk/";
static char *filesystemtype="nfs";
static unsigned long  mountflags = MS_MGC_VAL | MS_REMOUNT | MS_RDONLY;
static char *data = "";
//static const void *data = "rsize=8192,wsize=8192";

int main(){
        int ret = 0;
                ret = mount(source, target, filesystemtype,mountflags, data);
// these arguments makes me stunned
                printf("ret is %d\n", ret);
                if (ret != 0){
                        printf("mount error happened!\n");
                        return -1;
                }


        printf("mount successfully! \n source: %s\n target: %s\n
filesystemtype: %s\n ",
                                                source, target,
filesystemtype);
/*      ret = umount (target);
        if (ret != 0){
                fprintf(stderr, "umount error happened!\n");
                return -1;
        }*/
        return 0;
}

thank you very much.

------=_Part_36576_28130262.1163070643671
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<div id="mb_0">
<div>Hi ,</div>
<div>&nbsp;&nbsp;&nbsp; I wrote a programme to use the mount api to access the remote NFS server. But after read the (man 2&nbsp;mount), I found i cannot find a way to achieve the goal. <font color="#cc0000">My&nbsp;problem is I donot know the mount api arguments been set correctly 
</font>.</div>
<div>&nbsp;&nbsp;&nbsp; This error is very funny. Because when i executed the file , some times it works ,but at most time, It failed.</div>
<div>&nbsp;</div>
<div>I added my file following:</div>
<div>&nbsp;&nbsp;&nbsp; 
<p>#include &lt;sys/mount.h&gt;<br>#include &lt;linux/fs.h&gt;<br>#include &lt;stdio.h&gt;<br>#include &lt;sys/param.h&gt;</p>
<p>static char *target=&quot;/mnt/gt11server&quot;;<br>static char *source=&quot;192.168.0.11:/mnt/ramdisk/&quot;;<br>static char *filesystemtype=&quot;nfs&quot;;<br>static unsigned long&nbsp; mountflags = MS_MGC_VAL | MS_REMOUNT | MS_RDONLY; 
<br>static char *data = &quot;&quot;;<br>//static const void *data = &quot;rsize=8192,wsize=8192&quot;;</p>
<p>int main(){<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int ret = 0;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret = mount(<font color="#ff6600">source, target, filesystemtype,mountflags, data</font>);&nbsp; // these&nbsp;arguments makes me&nbsp;stunned<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; printf(&quot;ret is %d\n&quot;, ret); 
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (ret != 0){<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; printf(&quot;mount error happened!\n&quot;);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return -1;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }</p>
<p><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; printf(&quot;mount successfully! \n source: %s\n target: %s\n filesystemtype: %s\n &quot;,<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; source, target, filesystemtype);<br>/*&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ret = umount (target); 
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if (ret != 0){<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; fprintf(stderr, &quot;umount error happened!\n&quot;);<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return -1;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }*/<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return 0;<br>}<br></p>
<p>thank you very much.</p></div></div><br style="DISPLAY: none; FONT-SIZE: 8px" clear="all">

------=_Part_36576_28130262.1163070643671--


--===============1384000070==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--===============1384000070==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1384000070==--
