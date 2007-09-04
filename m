From: "Guilherme Vilela" <vilela.list@gmail.com>
Subject: Problem to recognize that the file system is full
Date: Tue, 4 Sep 2007 11:01:41 -0300
Message-ID: <89a10cbc0709040701x4a6e0e3cna375e714a19b19e4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0826512958=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISYyL-0005eD-RZ
	for nfs@lists.sourceforge.net; Tue, 04 Sep 2007 07:01:41 -0700
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ISYyN-0005JV-Si
	for nfs@lists.sourceforge.net; Tue, 04 Sep 2007 07:01:46 -0700
Received: by ug-out-1314.google.com with SMTP id m2so415126uge
	for <nfs@lists.sourceforge.net>; Tue, 04 Sep 2007 07:01:42 -0700 (PDT)
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

--===============0826512958==
Content-Type: multipart/alternative;
	boundary="----=_Part_22674_31286818.1188914501898"

------=_Part_22674_31286818.1188914501898
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
I'm tryng to mount a nfs file system with the option async and run a program
that writes to the file system. The problem is that the program keep writing
even when the file system is full. It appears that the nfs dont see that the
file system is full and keeps writing to the cache. This program does'nt
occur when mounting with the sync option or with async and noac option, but
the performance get very poor and that is important to my application. The
problem doesnt occur too with the local file system. I'm running linux
centos 5.0.

Bellow is my test program.
Any idea how to resolve this problem?

Thanks,
Guilherme


//io-stress.cpp

#include <iostream>
#include <fstream>
#include <string>

using namespace std;

int main()
{
        int i = 0;
        string roller( "|/-\\" );
        string sample( "*", 1024 );
        ofstream ofs( "io-stress.txt" );
        ofs.exceptions( ios::failbit | ios::badbit );

        while ( ofs )
        {
                ofs << sample << endl << flush;
                ofs.flush();
                if ( i == 3 )
                        i = 0;
                cout << "\b" << roller[i++];
        }
        ofs.close();
        return 0;
}

------=_Part_22674_31286818.1188914501898
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,<br>I&#39;m tryng to mount a nfs file system with the option async and run a program that writes to the file system. The problem is that the program keep writing even when the file system is full. It appears that the nfs dont see that the file system is full and keeps writing to the cache. This program does&#39;nt occur when mounting with the sync option or with async and noac option, but the performance get very poor and that is important to my application. The problem doesnt occur too with the local file system. I&#39;m running linux centos 
5.0.<br><br>Bellow is my test program.<br>Any idea how to resolve this problem?<br><br>Thanks,<br>Guilherme<br><br><br>//io-stress.cpp<br><br>#include &lt;iostream&gt;<br>#include &lt;fstream&gt;<br>#include &lt;string&gt;
<br><br>using namespace std;<br><br>int main()<br>{<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; int i = 0;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; string roller( &quot;|/-\\&quot; );<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; string sample( &quot;*&quot;, 1024 );<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ofstream ofs( &quot;io-stress.txt&quot; );
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ofs.exceptions( ios::failbit | ios::badbit );<br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; while ( ofs )<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; {<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ofs &lt;&lt; sample &lt;&lt; endl &lt;&lt; flush;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ofs.flush();<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; if ( i == 3 )
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; i = 0;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; cout &lt;&lt; &quot;\b&quot; &lt;&lt; roller[i++];<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; }<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ofs.close();<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; return 0;<br>}<br><br>

------=_Part_22674_31286818.1188914501898--


--===============0826512958==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0826512958==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0826512958==--
