Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:61011 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab1G3ExZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 00:53:25 -0400
Received: from [192.168.0.251] (PBENDER1.bendercasa.net [192.168.0.251])
	(authenticated bits=0)
	by server.bendercasa.net (8.13.8/8.13.8) with ESMTP id p6U4rN4s005678
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 21:53:24 -0700
Message-ID: <4E338E44.40705@san.rr.com>
Date: Fri, 29 Jul 2011 21:53:24 -0700
From: Paul Bender <pebender@san.rr.com>
Reply-To: pebender@san.rr.com
To: linux-nfs@vger.kernel.org
Subject: problem with running configure with the dash shell
Content-Type: multipart/mixed;
 boundary="------------030902060109080101070000"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------030902060109080101070000
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

nfs-utils' configure script fails to run when /bin/sh is the dash shell. 
The attached patch fixes the problem for me.

--------------030902060109080101070000
Content-Type: application/gzip;
 name="nfs-utils-1.2.4-dash.patch.gz"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfs-utils-1.2.4-dash.patch.gz"

H4sICDwFM04AA25mcy11dGlscy0xLjIuNC1kYXNoLnBhdGNoAJ1SXYviMBR9tr/ibvFBqbGpirKK
YMftOoLbEXWfREo/Ug0TktI08/HvN53qTrvDMLB5SG9Ozzk53JuEpikgP1Q58FQiVVAmkdMf9EdI
sMSOBU/pWeWkH8YfCJw8NwgGQuhLl9YAOw7CYzTEgMdTjKejQR/fFiA8wdiwLOvL265GEzT4Do4z
HY6nw8kHo8UCkOOMes4IrOt3sTCglWfxmfAgC4vLvP1Mi8tTyHr/4K9EQldju+1y5fnB1j3czw3U
oikURBZgtmtkE+ZzMLXCnEFxIdywPuU1aNACvVKRQwaUg61kbjMRh8yOKLcrYYXWz+/11SARcLsO
pdDOoLKHevQ3NMpJ+DiDlOo6EZxoPWGfJP2mo1JekJyHrJm3YVvT6N8p1Zu7DPa/7/aHTo3Y1a1z
fwXLB//H+rB+8N1NR9c/16ugIvXgeA1RE1VtNU9d3c//EVda0Hnc3SrwfPdu43WUokk566OG773N
Ntgfdmt/1TkilFAZRoygknLSpt5LzFRCoDyDVFkm8gIKAeGT0ECkzudXYDSK2KPmd0+l63szCS+9
9MP6O/TbWOKLEJIEb7Lymc2AMEmaMBflmHrGHyvQX8+hAwAA

--------------030902060109080101070000--
