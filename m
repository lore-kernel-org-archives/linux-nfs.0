From: Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Subject: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Fri, 5 Sep 2008 12:19:40 -0700
Message-ID: <20080905191939.GG22796@merfinllc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="L+ofChggJdETEG3Y"
To: neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no, linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49775 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754160AbYIETTy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2008 15:19:54 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KbgqW-0000GX-Aj
	for linux-nfs@vger.kernel.org; Sat, 06 Sep 2008 05:19:52 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--L+ofChggJdETEG3Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all,

  We're hitting some bad behavior in NFS v3.  The situation is this:

   machine A - NFS server

   machine B - NFS client (writer)
   machine C - NFS client (reader)

   (all machines x86 SMP)

  machine A exports a directory on ext3 filesystem:

	/srv/home       192.168.0.0/24(rw,sync,no_subtree_check)

  machines B and C mount that directory normally

        mount A:/srv/home /mntpnt

  machine B opens a file and writes to it (think a log file)

  machine C stats that file, opens it and reads it (think tailing the
                                                    log file)


  The issue is that machine C will often see large blocks of NULLs
(zeros) in the file.  If you do the same read again just after you see
the block of NULLs you will see proper the data.

  Attached are two simple python programs that demonstrate the problem.

  To use them (they will write to a file called test-nfs in CWD):

 (on machine B in one window)

   python writer.py

 (on machine C in another window)

   python reader.py

  
  reader.py will die when it sees NULLs in the file.  Usually for us
this happens after about 60s (two timeouts I think).   The first NULL is
usually either at index 4000 or 8000 depending on the kernel.


  Now the version of the kernel the server is running doesn't seem to
matter.  The reader also doesn't seem to matter (though I didn't test
this completely).  The writer seems to be the issue:

  Writer_Version     Outcome:
  <= 2.6.19          OK
  >= 2.6.20	     BAD

  I've tested both vanilla kernel.org kernels and Ubuntu 8.04 kernels.

  I can try to bisect between 2.6.19 <-> 2.6.20. 

  Anyone else hitting this problem?  Any better ideas?


  					Thanks,
					=a=


   
-- 
===================
Aaron Straus
aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org

--L+ofChggJdETEG3Y
Content-Type: text/x-python; charset=us-ascii
Content-Disposition: attachment; filename="reader.py"

#!/usr/bin/env python
import time
import os

def run(file_name):
    data = ''
    last_data_len = len(data)
    last_size = os.stat(file_name).st_size

    while True:
        st_size = os.stat(file_name).st_size
        if st_size != last_size:
            print 'size changed @ %s' % time.asctime()

        data = open(file_name).read()

        if len(data) != last_data_len:
            print 'new data arrived @ %s' % time.asctime()
            print repr(data[-50:])


        if '\0' in data:
            first_index = data.index('\0')
            data_fragment = data[first_index-50:first_index+50]
            print 'Detected NULL @ %d %s' % (first_index, repr(data_fragment))
            break

        time.sleep(0.250)

        last_data_len = len(data)
        last_size = st_size

if __name__ == '__main__':
    run('test-nfs')

--L+ofChggJdETEG3Y
Content-Type: text/x-python; charset=us-ascii
Content-Disposition: attachment; filename="writer.py"

#!/usr/bin/env python
import time

def run(file_name):
    fp = open(file_name, 'w')

    count = 1

    while count:
        fp.write('meow\n' * 800)
        fp.flush()
        time.sleep(32)

    fp.close()

if __name__ == '__main__':
    run('test-nfs')

--L+ofChggJdETEG3Y
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
--L+ofChggJdETEG3Y
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--L+ofChggJdETEG3Y--


